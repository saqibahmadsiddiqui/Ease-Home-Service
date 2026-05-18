from __future__ import annotations

import uuid
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field

from app.core.security.firebase_auth import get_current_user, require_user
from app.services.antigravity.intent_agent import parse_user_intent
from app.services.antigravity.scheduling_agent import suggest_schedule
from app.services.firebase.firestore_service import get_document
from app.core.config.settings import get_settings

router = APIRouter(prefix="/ai", tags=["AI Orchestration"])
_settings = get_settings()


class IntentRequest(BaseModel):
    natural_language_request: str = Field(..., min_length=5, max_length=1000)
    session_id: str | None = None


class ScheduleRequest(BaseModel):
    provider_id: str
    session_id: str | None = None


@router.post("/parse-intent")
async def parse_intent_endpoint(
    body: IntentRequest,
    current_user: Annotated[dict, Depends(require_user)],
) -> dict:
    session_id = body.session_id or str(uuid.uuid4())
    result = await parse_user_intent(body.natural_language_request, session_id)
    return {"session_id": session_id, "result": result}


@router.post("/suggest-schedule")
async def suggest_schedule_endpoint(
    body: ScheduleRequest,
    current_user: Annotated[dict, Depends(require_user)],
) -> dict:
    provider = await get_document(_settings.FIRESTORE_PROVIDERS_COLLECTION, body.provider_id)
    if not provider:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Provider not found")
    session_id = body.session_id or str(uuid.uuid4())
    result = await suggest_schedule(
        provider_id=body.provider_id,
        availability=provider.get("availability", []),
        requested_at=None,
        session_id=session_id,
    )
    return {"session_id": session_id, "result": result}
