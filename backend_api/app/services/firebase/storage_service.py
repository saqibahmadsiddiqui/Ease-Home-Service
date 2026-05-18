from __future__ import annotations

import asyncio
import uuid
from typing import Optional

from google.cloud import storage

from app.core.config.settings import get_settings

_settings = get_settings()
_storage_client: Optional[storage.Client] = None


def _get_client() -> storage.Client:
    global _storage_client
    if _storage_client is None:
        _storage_client = storage.Client(project=_settings.FIREBASE_PROJECT_ID)
    return _storage_client


async def upload_file(
    file_bytes: bytes,
    destination_path: str,
    content_type: str = "application/octet-stream",
) -> str:
    """Upload bytes to Firebase Cloud Storage and return the public URL."""
    def _upload() -> str:
        client = _get_client()
        bucket = client.bucket(_settings.FIREBASE_STORAGE_BUCKET)
        blob = bucket.blob(destination_path)
        blob.upload_from_string(file_bytes, content_type=content_type)
        blob.make_public()
        return blob.public_url

    return await asyncio.to_thread(_upload)


async def upload_profile_photo(uid: str, file_bytes: bytes, content_type: str = "image/jpeg") -> str:
    path = f"profile_photos/{uid}/{uuid.uuid4()}.jpg"
    return await upload_file(file_bytes, path, content_type)


async def upload_kyc_document(provider_uid: str, doc_type: str, file_bytes: bytes, content_type: str = "image/jpeg") -> str:
    path = f"kyc/{provider_uid}/{doc_type}/{uuid.uuid4()}.jpg"
    return await upload_file(file_bytes, path, content_type)


async def upload_evidence(booking_id: str, file_bytes: bytes, content_type: str = "image/jpeg") -> str:
    path = f"evidence/{booking_id}/{uuid.uuid4()}.jpg"
    return await upload_file(file_bytes, path, content_type)


async def delete_file(public_url: str) -> bool:
    def _delete() -> bool:
        try:
            client = _get_client()
            bucket = client.bucket(_settings.FIREBASE_STORAGE_BUCKET)
            blob_name = public_url.split(f"{_settings.FIREBASE_STORAGE_BUCKET}/")[1]
            blob = bucket.blob(blob_name)
            blob.delete()
            return True
        except Exception:
            return False

    return await asyncio.to_thread(_delete)
