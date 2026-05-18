from __future__ import annotations

from datetime import datetime
from enum import Enum
from typing import Literal, Optional

from pydantic import BaseModel, Field


class DisputeStatus(str, Enum):
    OPEN = "OPEN"
    UNDER_REVIEW = "UNDER_REVIEW"
    RESOLVED = "RESOLVED"
    ESCALATED = "ESCALATED"


class DisputeCreate(BaseModel):
    booking_id: str
    raised_by: Literal["user", "provider"]
    reason: str = Field(..., min_length=10, max_length=1000)
    evidence_urls: list[str] = Field(default_factory=list)


class DisputeResolution(BaseModel):
    resolved_in_favor_of: Literal["user", "provider"]
    resolution_note: str = Field(..., min_length=5, max_length=1000)
    refund_amount: Optional[float] = Field(None, ge=0)


class Dispute(BaseModel):
    dispute_id: str
    booking_id: str
    user_id: str
    provider_id: str
    raised_by: Literal["user", "provider"]
    reason: str
    evidence_urls: list[str] = Field(default_factory=list)
    status: DisputeStatus = DisputeStatus.OPEN
    ai_analysis: Optional[dict] = None
    resolution: Optional[DisputeResolution] = None
    resolved_by: Optional[str] = None  # admin uid
    created_at: datetime
    updated_at: datetime
