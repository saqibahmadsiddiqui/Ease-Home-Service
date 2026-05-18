from __future__ import annotations

from datetime import datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, Field


class BookingStatus(str, Enum):
    PENDING = "PENDING"
    MATCHED = "MATCHED"
    CONFIRMED = "CONFIRMED"
    ACCEPTED = "ACCEPTED"
    EN_ROUTE = "EN_ROUTE"
    IN_PROGRESS = "IN_PROGRESS"
    COMPLETED = "COMPLETED"
    CLOSED = "CLOSED"
    CANCELLED = "CANCELLED"
    DISPUTED = "DISPUTED"


# Valid transitions for the state machine
VALID_TRANSITIONS: dict[BookingStatus, list[BookingStatus]] = {
    BookingStatus.PENDING: [BookingStatus.MATCHED, BookingStatus.CANCELLED],
    BookingStatus.MATCHED: [BookingStatus.CONFIRMED, BookingStatus.CANCELLED],
    BookingStatus.CONFIRMED: [BookingStatus.ACCEPTED, BookingStatus.CANCELLED],
    BookingStatus.ACCEPTED: [BookingStatus.EN_ROUTE, BookingStatus.CANCELLED],
    BookingStatus.EN_ROUTE: [BookingStatus.IN_PROGRESS],
    BookingStatus.IN_PROGRESS: [BookingStatus.COMPLETED, BookingStatus.DISPUTED],
    BookingStatus.COMPLETED: [BookingStatus.CLOSED],
    BookingStatus.CLOSED: [],
    BookingStatus.CANCELLED: [],
    BookingStatus.DISPUTED: [BookingStatus.CLOSED],
}


class ServiceLocation(BaseModel):
    address: str = Field(..., min_length=5, max_length=300)
    latitude: float = Field(..., ge=-90.0, le=90.0)
    longitude: float = Field(..., ge=-180.0, le=180.0)
    city: str


class PriceBreakdown(BaseModel):
    base_rate: float = Field(..., ge=0)
    complexity_multiplier: float = Field(1.0, ge=1.0)
    distance_fee: float = Field(0.0, ge=0)
    urgency_premium: float = Field(0.0, ge=0)
    surge_adjustment: float = Field(0.0, ge=0)
    loyalty_discount: float = Field(0.0, ge=0)
    final_price: float = Field(..., ge=0)


class BookingCreate(BaseModel):
    service_type: str = Field(..., min_length=2, max_length=100)
    description: str = Field(..., min_length=10, max_length=1000)
    location: ServiceLocation
    scheduled_at: Optional[datetime] = None
    is_urgent: bool = False
    media_urls: list[str] = Field(default_factory=list)


class BookingStatusUpdate(BaseModel):
    new_status: BookingStatus
    note: Optional[str] = Field(None, max_length=500)


class Booking(BaseModel):
    booking_id: str
    user_id: str
    provider_id: Optional[str] = None
    service_type: str
    description: str
    location: ServiceLocation
    status: BookingStatus = BookingStatus.PENDING
    scheduled_at: Optional[datetime] = None
    is_urgent: bool = False
    media_urls: list[str] = Field(default_factory=list)
    price: Optional[PriceBreakdown] = None
    status_history: list[dict] = Field(default_factory=list)
    created_at: datetime
    updated_at: datetime


class Receipt(BaseModel):
    receipt_id: str
    booking_id: str
    user_id: str
    provider_id: str
    service_type: str
    completed_at: datetime
    price: PriceBreakdown
    provider_name: str
    user_name: str
    location_address: str
    generated_at: datetime
