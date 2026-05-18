from __future__ import annotations

from datetime import datetime, timezone
from typing import Annotated
import uuid

import firebase_admin
from firebase_admin import auth as firebase_auth_admin
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field

from app.core.config.settings import Settings, get_settings
from app.core.security.firebase_auth import (
    create_access_token,
    create_refresh_token,
    decode_token,
    get_current_user,
    hash_pin,
    verify_pin,
    verify_firebase_id_token,
)
from app.services.firebase.firestore_service import (
    create_document,
    get_document,
    get_user_by_uid,
    update_document,
)

router = APIRouter(prefix="/auth", tags=["Authentication"])


# ---------------------------------------------------------------------------
# Request / Response schemas
# ---------------------------------------------------------------------------

class RegisterRequest(BaseModel):
    phone: str = Field(..., pattern=r"^\+92[0-9]{10}$")
    role: str = Field(..., pattern=r"^(user|provider)$")
    name: str = Field(..., min_length=2, max_length=100)
    firebase_id_token: str


class RegisterResponse(BaseModel):
    uid: str
    access_token: str
    refresh_token: str
    role: str


class OtpVerifyRequest(BaseModel):
    phone: str
    firebase_id_token: str  # Firebase handles OTP; we verify the resulting ID token


class OtpVerifyResponse(BaseModel):
    uid: str
    access_token: str
    refresh_token: str
    is_new_user: bool


class RefreshRequest(BaseModel):
    refresh_token: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str


class AdminSignInRequest(BaseModel):
    email: str
    password: str
    pin: str = Field(..., min_length=4, max_length=4, pattern=r"^\d{4}$")


class AdminTokenResponse(BaseModel):
    uid: str
    access_token: str
    refresh_token: str
    role: str = "admin"


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------

@router.post("/register", response_model=RegisterResponse, status_code=status.HTTP_201_CREATED)
async def register(
    body: RegisterRequest,
    settings: Annotated[Settings, Depends(get_settings)],
) -> RegisterResponse:
    decoded = await verify_firebase_id_token(body.firebase_id_token)
    uid = decoded["uid"]
    collection = f"{body.role}s"  # "users" or "providers"

    existing = await get_document(collection, uid)
    if existing:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="User already registered")

    doc = {
        "uid": uid,
        "phone": body.phone,
        "full_name": body.name,
        "role": body.role,
        "is_verified": False,
        "total_bookings": 0,
        "fcm_token": None,
    }
    await create_document(collection, doc, uid)

    payload = {"sub": uid, "role": body.role, "phone": body.phone}
    return RegisterResponse(
        uid=uid,
        access_token=create_access_token(payload, settings),
        refresh_token=create_refresh_token(payload, settings),
        role=body.role,
    )


@router.post("/verify-otp", response_model=OtpVerifyResponse)
async def verify_otp(
    body: OtpVerifyRequest,
    settings: Annotated[Settings, Depends(get_settings)],
) -> OtpVerifyResponse:
    decoded = await verify_firebase_id_token(body.firebase_id_token)
    uid = decoded["uid"]

    # Determine role from Firestore
    user_doc = await get_document("users", uid)
    provider_doc = await get_document("providers", uid)
    doc = user_doc or provider_doc
    is_new = doc is None
    role = (doc or {}).get("role", "user")

    if doc:
        await update_document(doc["role"] + "s", uid, {"is_verified": True})

    payload = {"sub": uid, "role": role, "phone": body.phone}
    return OtpVerifyResponse(
        uid=uid,
        access_token=create_access_token(payload, settings),
        refresh_token=create_refresh_token(payload, settings),
        is_new_user=is_new,
    )


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(
    body: RefreshRequest,
    settings: Annotated[Settings, Depends(get_settings)],
) -> TokenResponse:
    payload = decode_token(body.refresh_token, settings)
    if payload.get("type") != "refresh":
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not a refresh token")
    new_payload = {"sub": payload["sub"], "role": payload["role"], "phone": payload.get("phone", "")}
    return TokenResponse(
        access_token=create_access_token(new_payload, settings),
        refresh_token=create_refresh_token(new_payload, settings),
    )


@router.get("/me")
async def get_me(
    current_user: Annotated[dict, Depends(get_current_user)],
) -> dict:
    uid = current_user["sub"]
    role = current_user["role"]
    collection = role + "s" if role in ("user", "provider") else "admins"
    doc = await get_document(collection, uid)
    if not doc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Profile not found")
    return doc


@router.post("/admin/sign-in", response_model=AdminTokenResponse)
async def admin_sign_in(
    body: AdminSignInRequest,
    settings: Annotated[Settings, Depends(get_settings)],
) -> AdminTokenResponse:
    if not verify_pin(body.pin, settings.ADMIN_PIN_HASH):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid admin PIN")

    try:
        firebase_user = firebase_auth_admin.get_user_by_email(body.email)
    except Exception:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Admin not found")

    uid = firebase_user.uid
    payload = {"sub": uid, "role": "admin", "email": body.email}
    return AdminTokenResponse(
        uid=uid,
        access_token=create_access_token(payload, settings),
        refresh_token=create_refresh_token(payload, settings),
    )
