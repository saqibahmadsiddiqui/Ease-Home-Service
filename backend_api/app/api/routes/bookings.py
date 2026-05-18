from __future__ import annotations

import uuid
from datetime import datetime, timezone
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field

from app.core.security.firebase_auth import get_current_user, require_user
from app.models.booking import (
    Booking,
    BookingCreate,
    BookingStatus,
    BookingStatusUpdate,
    VALID_TRANSITIONS,
    PriceBreakdown,
)
from app.services.firebase.firestore_service import (
    add_booking_status_event,
    create_document,
    create_receipt,
    get_booking,
    get_document,
    query_collection,
    update_document,
)
from app.services.firebase.fcm_service import send_booking_status_notification
from app.services.antigravity.pricing_agent import calculate_price
from app.services.antigravity.matching_agent import match_provider
from app.core.config.settings import get_settings

router = APIRouter(prefix="/bookings", tags=["Bookings"])
_settings = get_settings()


@router.post("/", status_code=status.HTTP_201_CREATED)
async def create_booking(
    body: BookingCreate,
    current_user: Annotated[dict, Depends(require_user)],
) -> dict:
    user_id = current_user["sub"]
    booking_id = f"BK-{str(uuid.uuid4())[:8].upper()}"
    session_id = str(uuid.uuid4())

    doc = {
        "booking_id": booking_id,
        "user_id": user_id,
        "provider_id": None,
        "service_type": body.service_type,
        "description": body.description,
        "location": body.location.model_dump(),
        "status": BookingStatus.PENDING.value,
        "scheduled_at": body.scheduled_at.isoformat() if body.scheduled_at else None,
        "is_urgent": body.is_urgent,
        "media_urls": body.media_urls,
        "price": None,
        "status_history": [{
            "from": None,
            "to": BookingStatus.PENDING.value,
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }],
        "session_id": session_id,
    }
    await create_document(_settings.FIRESTORE_BOOKINGS_COLLECTION, doc, booking_id)

    # Auto-match via Antigravity
    loc = body.location
    matched = await match_provider(
        service_type=body.service_type,
        city=loc.city,
        user_lat=loc.latitude,
        user_lon=loc.longitude,
        session_id=session_id,
        top_k=1,
    )
    if matched:
        provider = matched[0]
        provider_id = provider["uid"]
        provider_loc = provider.get("location") or {}
        base_rate = next(
            (s["rate_per_hour"] for s in provider.get("skills", []) if s.get("skill") == body.service_type),
            None,
        )
        price = await calculate_price(
            user_id=user_id,
            service_type=body.service_type,
            city=loc.city,
            provider_lat=provider_loc.get("latitude", loc.latitude),
            provider_lon=provider_loc.get("longitude", loc.longitude),
            user_lat=loc.latitude,
            user_lon=loc.longitude,
            base_rate=base_rate,
            is_urgent=body.is_urgent,
        )
        await update_document(_settings.FIRESTORE_BOOKINGS_COLLECTION, booking_id, {
            "provider_id": provider_id,
            "price": price.model_dump(),
            "status": BookingStatus.MATCHED.value,
        })
        await add_booking_status_event(booking_id, BookingStatus.PENDING.value, BookingStatus.MATCHED.value)

        # Push FCM
        user_doc = await get_document(_settings.FIRESTORE_USERS_COLLECTION, user_id)
        await send_booking_status_notification(
            user_fcm=user_doc.get("fcm_token") if user_doc else None,
            provider_fcm=provider.get("fcm_token"),
            booking_id=booking_id,
            new_status=BookingStatus.MATCHED.value,
            service_type=body.service_type,
        )

    return {"booking_id": booking_id, "status": "created"}


@router.get("/{booking_id}")
async def get_booking_detail(
    booking_id: str,
    current_user: Annotated[dict, Depends(get_current_user)],
) -> dict:
    booking = await get_booking(booking_id)
    if not booking:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")
    uid = current_user["sub"]
    role = current_user["role"]
    if role not in ("admin",) and booking.get("user_id") != uid and booking.get("provider_id") != uid:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")
    return booking


@router.patch("/{booking_id}/status")
async def update_booking_status(
    booking_id: str,
    body: BookingStatusUpdate,
    current_user: Annotated[dict, Depends(get_current_user)],
) -> dict:
    booking = await get_booking(booking_id)
    if not booking:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")

    current_status = BookingStatus(booking["status"])
    valid_next = VALID_TRANSITIONS.get(current_status, [])
    if body.new_status not in valid_next:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"Invalid transition: {current_status} → {body.new_status}",
        )

    await add_booking_status_event(booking_id, current_status.value, body.new_status.value, body.note)

    # Generate receipt when CLOSED
    if body.new_status == BookingStatus.CLOSED and booking.get("price"):
        await create_receipt(booking, booking["price"])

    # FCM push
    user_doc = await get_document(_settings.FIRESTORE_USERS_COLLECTION, booking["user_id"])
    provider_doc = await get_document(_settings.FIRESTORE_PROVIDERS_COLLECTION, booking.get("provider_id", ""))
    await send_booking_status_notification(
        user_fcm=user_doc.get("fcm_token") if user_doc else None,
        provider_fcm=provider_doc.get("fcm_token") if provider_doc else None,
        booking_id=booking_id,
        new_status=body.new_status.value,
        service_type=booking["service_type"],
    )
    return {"booking_id": booking_id, "status": body.new_status.value}


@router.get("/user/me")
async def get_user_bookings(
    current_user: Annotated[dict, Depends(require_user)],
) -> list:
    uid = current_user["sub"]
    return await query_collection(_settings.FIRESTORE_BOOKINGS_COLLECTION, filters=[("user_id", "==", uid)])
