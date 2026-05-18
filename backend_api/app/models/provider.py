from __future__ import annotations

from datetime import datetime, time
from typing import Literal, Optional
from pydantic import BaseModel, Field, field_validator
import re


class SkillRate(BaseModel):
    skill: str = Field(..., min_length=2, max_length=50)
    rate_per_hour: float = Field(..., gt=0, description="Rate in PKR per hour")


class AvailabilitySlot(BaseModel):
    day: Literal["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    start_time: str = Field(..., pattern=r"^\d{2}:\d{2}$")
    end_time: str = Field(..., pattern=r"^\d{2}:\d{2}$")


class ProviderLocation(BaseModel):
    latitude: float = Field(..., ge=-90.0, le=90.0)
    longitude: float = Field(..., ge=-180.0, le=180.0)
    city: str


class KYCDocuments(BaseModel):
    cnic_front_url: Optional[str] = None
    cnic_back_url: Optional[str] = None
    certificate_urls: list[str] = Field(default_factory=list)
    kyc_status: Literal["pending", "approved", "rejected"] = "pending"
    reviewed_by: Optional[str] = None
    reviewed_at: Optional[datetime] = None


class ProviderBase(BaseModel):
    full_name: str = Field(..., min_length=2, max_length=100)
    phone: str = Field(..., description="E.164 +92XXXXXXXXXX")
    cnic: str = Field(..., description="CNIC without dashes, 13 digits")
    city: str = Field(..., min_length=2, max_length=50)

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str) -> str:
        if not re.match(r"^\+92[0-9]{10}$", v):
            raise ValueError("Phone must be +92XXXXXXXXXX")
        return v

    @field_validator("cnic")
    @classmethod
    def validate_cnic(cls, v: str) -> str:
        if not re.match(r"^\d{13}$", v):
            raise ValueError("CNIC must be 13 digits without dashes")
        return v


class ProviderCreate(ProviderBase):
    password: str = Field(..., min_length=8)
    skills: list[SkillRate] = Field(..., min_length=1)
    experience_years: int = Field(..., ge=0, le=50)
    coverage_radius_km: float = Field(..., gt=0, le=100)
    availability: list[AvailabilitySlot] = Field(..., min_length=1)


class ProviderProfile(ProviderBase):
    uid: str
    role: Literal["provider"] = "provider"
    skills: list[SkillRate] = Field(default_factory=list)
    experience_years: int = 0
    coverage_radius_km: float = 10.0
    availability: list[AvailabilitySlot] = Field(default_factory=list)
    kyc: KYCDocuments = Field(default_factory=KYCDocuments)
    is_active: bool = False
    is_verified: bool = False
    is_online: bool = False
    location: Optional[ProviderLocation] = None
    profile_photo_url: Optional[str] = None
    rating: float = Field(0.0, ge=0.0, le=5.0)
    total_reviews: int = 0
    total_jobs_completed: int = 0
    total_earnings: float = 0.0
    fcm_token: Optional[str] = None
    created_at: datetime
    updated_at: datetime


class ProviderUpdate(BaseModel):
    is_online: Optional[bool] = None
    location: Optional[ProviderLocation] = None
    fcm_token: Optional[str] = None
    availability: Optional[list[AvailabilitySlot]] = None
    coverage_radius_km: Optional[float] = Field(None, gt=0, le=100)


class ProviderPublic(BaseModel):
    uid: str
    full_name: str
    skills: list[SkillRate]
    city: str
    rating: float
    total_reviews: int
    total_jobs_completed: int
    coverage_radius_km: float
    profile_photo_url: Optional[str] = None
    is_online: bool = False
