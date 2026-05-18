from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status

from app.core.security.firebase_auth import get_current_user, require_provider
from app.models.provider import ProviderUpdate
from app.services.firebase.firestore_service import (
    get_document,
    query_collection,
    update_document,
)
from app.core.config.settings import get_settings

router = APIRouter(prefix="/provider", tags=["Provider"])
_settings = get_settings()


@router.get("/profile")
async def get_provider_profile(
    current_user: Annotated[dict, Depends(require_provider)],
) -> dict:
    uid = current_user["sub"]
    doc = await get_document(_settings.FIRESTORE_PROVIDERS_COLLECTION, uid)
    if not doc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Provider profile not found")
    return doc


@router.patch("/profile")
async def update_provider_profile(
    body: ProviderUpdate,
    current_user: Annotated[dict, Depends(require_provider)],
) -> dict:
    uid = current_user["sub"]
    update_data = body.model_dump(exclude_none=True)
    if not update_data:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No data to update")
    await update_document(_settings.FIRESTORE_PROVIDERS_COLLECTION, uid, update_data)
    return {"message": "Profile updated"}


@router.get("/jobs")
async def get_provider_jobs(
    current_user: Annotated[dict, Depends(require_provider)],
) -> list:
    uid = current_user["sub"]
    return await query_collection(
        _settings.FIRESTORE_BOOKINGS_COLLECTION,
        filters=[("provider_id", "==", uid)],
    )


@router.get("/earnings")
async def get_provider_earnings(
    current_user: Annotated[dict, Depends(require_provider)],
) -> dict:
    uid = current_user["sub"]
    jobs = await query_collection(
        _settings.FIRESTORE_BOOKINGS_COLLECTION,
        filters=[("provider_id", "==", uid), ("status", "==", "CLOSED")],
        limit=1000,
    )
    total = sum(
        j.get("price", {}).get("final_price", 0.0) for j in jobs if j.get("price")
    )
    return {"total_earnings": round(total, 2), "jobs_completed": len(jobs)}
