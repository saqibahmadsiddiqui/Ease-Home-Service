from __future__ import annotations

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class ReviewCreate(BaseModel):
    booking_id: str
    provider_id: str
    rating: float = Field(..., ge=1.0, le=5.0)
    comment: Optional[str] = Field(None, max_length=500)
    media_urls: list[str] = Field(default_factory=list)


class Review(BaseModel):
    review_id: str
    booking_id: str
    user_id: str
    provider_id: str
    rating: float = Field(..., ge=1.0, le=5.0)
    comment: Optional[str] = None
    media_urls: list[str] = Field(default_factory=list)
    is_flagged: bool = False
    created_at: datetime
