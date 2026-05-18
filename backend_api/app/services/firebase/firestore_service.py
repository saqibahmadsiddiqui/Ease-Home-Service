from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Optional
import uuid

from google.cloud import firestore
from google.cloud.firestore_v1.async_client import AsyncClient

from app.core.config.settings import get_settings

_settings = get_settings()
_db: Optional[AsyncClient] = None


def get_db() -> AsyncClient:
    global _db
    if _db is None:
        _db = firestore.AsyncClient(project=_settings.FIREBASE_PROJECT_ID)
    return _db


# ---------------------------------------------------------------------------
# Generic helpers
# ---------------------------------------------------------------------------

async def create_document(collection: str, data: dict, doc_id: Optional[str] = None) -> str:
    db = get_db()
    if doc_id is None:
        doc_id = str(uuid.uuid4())
    data["created_at"] = datetime.now(timezone.utc)
    data["updated_at"] = datetime.now(timezone.utc)
    await db.collection(collection).document(doc_id).set(data)
    return doc_id


async def get_document(collection: str, doc_id: str) -> Optional[dict]:
    db = get_db()
    doc = await db.collection(collection).document(doc_id).get()
    if doc.exists:
        return {"id": doc.id, **doc.to_dict()}
    return None


async def update_document(collection: str, doc_id: str, data: dict) -> None:
    db = get_db()
    data["updated_at"] = datetime.now(timezone.utc)
    await db.collection(collection).document(doc_id).update(data)


async def delete_document(collection: str, doc_id: str) -> None:
    db = get_db()
    await db.collection(collection).document(doc_id).delete()


async def query_collection(
    collection: str,
    filters: list[tuple[str, str, Any]] | None = None,
    order_by: Optional[str] = None,
    limit: int = 50,
) -> list[dict]:
    db = get_db()
    ref = db.collection(collection)
    if filters:
        for field, op, value in filters:
            ref = ref.where(field, op, value)
    if order_by:
        ref = ref.order_by(order_by)
    ref = ref.limit(limit)
    docs = await ref.get()
    return [{"id": doc.id, **doc.to_dict()} for doc in docs]


# ---------------------------------------------------------------------------
# User-specific
# ---------------------------------------------------------------------------

async def get_user_by_uid(uid: str) -> Optional[dict]:
    return await get_document(_settings.FIRESTORE_USERS_COLLECTION, uid)


async def get_user_booking_count(user_id: str) -> int:
    docs = await query_collection(
        _settings.FIRESTORE_BOOKINGS_COLLECTION,
        filters=[("user_id", "==", user_id), ("status", "==", "CLOSED")],
        limit=1000,
    )
    return len(docs)


# ---------------------------------------------------------------------------
# Provider-specific
# ---------------------------------------------------------------------------

async def get_providers_by_skill_and_city(skill: str, city: str) -> list[dict]:
    return await query_collection(
        _settings.FIRESTORE_PROVIDERS_COLLECTION,
        filters=[
            ("city", "==", city),
            ("is_active", "==", True),
            ("is_verified", "==", True),
        ],
        limit=100,
    )


async def count_online_providers(city: str) -> int:
    docs = await query_collection(
        _settings.FIRESTORE_PROVIDERS_COLLECTION,
        filters=[("city", "==", city), ("is_online", "==", True), ("is_active", "==", True)],
        limit=1000,
    )
    return len(docs)


async def count_total_active_providers(city: str) -> int:
    docs = await query_collection(
        _settings.FIRESTORE_PROVIDERS_COLLECTION,
        filters=[("city", "==", city), ("is_active", "==", True)],
        limit=1000,
    )
    return len(docs)


# ---------------------------------------------------------------------------
# Booking-specific
# ---------------------------------------------------------------------------

async def get_booking(booking_id: str) -> Optional[dict]:
    return await get_document(_settings.FIRESTORE_BOOKINGS_COLLECTION, booking_id)


async def add_booking_status_event(booking_id: str, old_status: str, new_status: str, note: Optional[str] = None) -> None:
    db = get_db()
    event = {
        "from": old_status,
        "to": new_status,
        "timestamp": datetime.now(timezone.utc),
        "note": note,
    }
    await db.collection(_settings.FIRESTORE_BOOKINGS_COLLECTION).document(booking_id).update(
        {
            "status": new_status,
            "status_history": firestore.ArrayUnion([event]),
            "updated_at": datetime.now(timezone.utc),
        }
    )


async def create_receipt(booking: dict, price_breakdown: dict) -> str:
    receipt_id = f"RCP-{str(uuid.uuid4())[:8].upper()}"
    receipt_data = {
        "receipt_id": receipt_id,
        "booking_id": booking["booking_id"],
        "user_id": booking["user_id"],
        "provider_id": booking["provider_id"],
        "service_type": booking["service_type"],
        "completed_at": booking["updated_at"],
        "price": price_breakdown,
        "generated_at": datetime.now(timezone.utc),
    }
    await create_document(_settings.FIRESTORE_RECEIPTS_COLLECTION, receipt_data, receipt_id)
    return receipt_id


# ---------------------------------------------------------------------------
# Antigravity trace log
# ---------------------------------------------------------------------------

async def log_antigravity_trace(trace: dict) -> str:
    return await create_document(_settings.FIRESTORE_ANTIGRAVITY_LOGS_COLLECTION, trace)
