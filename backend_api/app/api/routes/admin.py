from __future__ import annotations

import uuid
from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field

from app.core.security.firebase_auth import require_admin
from app.models.dispute import DisputeCreate, DisputeResolution, DisputeStatus
from app.services.firebase.firestore_service import (
    create_document,
    get_document,
    query_collection,
    update_document,
)
from app.services.antigravity.dispute_agent import analyze_dispute
from app.core.config.settings import get_settings

router = APIRouter(prefix="/admin", tags=["Admin"])
_settings = get_settings()


@router.get("/dashboard")
async def admin_dashboard(
    current_user: Annotated[dict, Depends(require_admin)],
) -> dict:
    users = await query_collection(_settings.FIRESTORE_USERS_COLLECTION, limit=1000)
    providers = await query_collection(_settings.FIRESTORE_PROVIDERS_COLLECTION, limit=1000)
    bookings = await query_collection(_settings.FIRESTORE_BOOKINGS_COLLECTION, limit=1000)
    disputes = await query_collection(_settings.FIRESTORE_DISPUTES_COLLECTION, limit=1000)
    return {
        "total_users": len(users),
        "total_providers": len(providers),
        "total_bookings": len(bookings),
        "open_disputes": sum(1 for d in disputes if d.get("status") == "OPEN"),
        "total_revenue": sum(
            b.get("price", {}).get("final_price", 0.0) for b in bookings if b.get("price")
        ),
    }


@router.get("/users")
async def list_users(current_user: Annotated[dict, Depends(require_admin)]) -> list:
    return await query_collection(_settings.FIRESTORE_USERS_COLLECTION)


@router.get("/providers")
async def list_providers(current_user: Annotated[dict, Depends(require_admin)]) -> list:
    return await query_collection(_settings.FIRESTORE_PROVIDERS_COLLECTION)


@router.get("/disputes")
async def list_disputes(current_user: Annotated[dict, Depends(require_admin)]) -> list:
    return await query_collection(_settings.FIRESTORE_DISPUTES_COLLECTION)


@router.post("/disputes/{dispute_id}/analyze")
async def analyze_dispute_endpoint(
    dispute_id: str,
    current_user: Annotated[dict, Depends(require_admin)],
) -> dict:
    dispute = await get_document(_settings.FIRESTORE_DISPUTES_COLLECTION, dispute_id)
    if not dispute:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Dispute not found")

    user_doc = await get_document(_settings.FIRESTORE_USERS_COLLECTION, dispute["user_id"]) or {}
    provider_doc = await get_document(_settings.FIRESTORE_PROVIDERS_COLLECTION, dispute["provider_id"]) or {}
    session_id = str(uuid.uuid4())

    result = await analyze_dispute(
        booking_id=dispute["booking_id"],
        dispute_reason=dispute["reason"],
        evidence_urls=dispute.get("evidence_urls", []),
        user_history={"total_bookings": user_doc.get("total_bookings", 0)},
        provider_history={
            "rating": provider_doc.get("rating", 0.0),
            "total_jobs": provider_doc.get("total_jobs_completed", 0),
        },
        session_id=session_id,
    )
    await update_document(_settings.FIRESTORE_DISPUTES_COLLECTION, dispute_id, {
        "ai_analysis": result,
        "status": DisputeStatus.UNDER_REVIEW.value,
    })
    return {"dispute_id": dispute_id, "analysis": result}


@router.post("/disputes/{dispute_id}/resolve")
async def resolve_dispute(
    dispute_id: str,
    body: DisputeResolution,
    current_user: Annotated[dict, Depends(require_admin)],
) -> dict:
    await update_document(_settings.FIRESTORE_DISPUTES_COLLECTION, dispute_id, {
        "resolution": body.model_dump(),
        "status": DisputeStatus.RESOLVED.value,
        "resolved_by": current_user["sub"],
    })
    return {"dispute_id": dispute_id, "status": "RESOLVED"}


@router.patch("/providers/{provider_id}/kyc")
async def update_kyc_status(
    provider_id: str,
    kyc_status: str,
    current_user: Annotated[dict, Depends(require_admin)],
) -> dict:
    if kyc_status not in ("approved", "rejected"):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid KYC status")
    await update_document(_settings.FIRESTORE_PROVIDERS_COLLECTION, provider_id, {
        "kyc.kyc_status": kyc_status,
        "kyc.reviewed_by": current_user["sub"],
        "is_verified": kyc_status == "approved",
        "is_active": kyc_status == "approved",
    })
    return {"provider_id": provider_id, "kyc_status": kyc_status}


@router.patch("/providers/{provider_id}/blacklist")
async def blacklist_provider(
    provider_id: str,
    current_user: Annotated[dict, Depends(require_admin)],
) -> dict:
    await update_document(_settings.FIRESTORE_PROVIDERS_COLLECTION, provider_id, {
        "is_active": False,
        "is_blacklisted": True,
    })
    return {"provider_id": provider_id, "status": "blacklisted"}
