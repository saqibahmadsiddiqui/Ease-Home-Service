from __future__ import annotations

from datetime import datetime
from typing import Literal, Optional

from pydantic import BaseModel, EmailStr, Field, field_validator
import re


class UserBase(BaseModel):
    full_name: str = Field(..., min_length=2, max_length=100)
    phone: str = Field(..., description="E.164 format e.g. +923001234567")
    email: Optional[EmailStr] = None
    language_preference: Literal["en", "ur"] = "en"

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str) -> str:
        pattern = r"^\+92[0-9]{10}$"
        if not re.match(pattern, v):
            raise ValueError("Phone must be in +92XXXXXXXXXX format")
        return v


class UserCreate(UserBase):
    password: str = Field(..., min_length=8, max_length=128)
    confirm_password: str

    @field_validator("confirm_password")
    @classmethod
    def passwords_match(cls, v: str, info) -> str:
        if "password" in info.data and v != info.data["password"]:
            raise ValueError("Passwords do not match")
        return v


class UserProfile(UserBase):
    uid: str
    role: Literal["user"] = "user"
    profile_photo_url: Optional[str] = None
    is_verified: bool = False
    total_bookings: int = 0
    loyalty_tier: int = 0
    fcm_token: Optional[str] = None
    created_at: datetime
    updated_at: datetime


class UserUpdate(BaseModel):
    full_name: Optional[str] = Field(None, min_length=2, max_length=100)
    email: Optional[EmailStr] = None
    language_preference: Optional[Literal["en", "ur"]] = None
    profile_photo_url: Optional[str] = None
    fcm_token: Optional[str] = None


class UserPublic(BaseModel):
    uid: str
    full_name: str
    profile_photo_url: Optional[str] = None
    total_bookings: int = 0
