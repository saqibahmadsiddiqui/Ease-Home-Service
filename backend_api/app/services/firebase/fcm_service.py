from __future__ import annotations

import asyncio
import logging
from typing import Optional

import httpx

from app.core.config.settings import get_settings

logger = logging.getLogger(__name__)
_settings = get_settings()

FCM_URL = "https://fcm.googleapis.com/v1/projects/{project_id}/messages:send"


async def _get_access_token() -> str:
    """Obtain an OAuth2 access token using the service account credentials."""
    import google.auth
    import google.auth.transport.requests
    credentials, _ = google.auth.default(scopes=["https://www.googleapis.com/auth/firebase.messaging"])
    request = google.auth.transport.requests.Request()
    credentials.refresh(request)
    return credentials.token


async def send_push_notification(
    fcm_token: str,
    title: str,
    body: str,
    data: Optional[dict] = None,
) -> bool:
    """Send a single FCM push notification."""
    try:
        access_token = await asyncio.to_thread(_get_access_token)
        url = FCM_URL.format(project_id=_settings.FIREBASE_PROJECT_ID)
        payload: dict = {
            "message": {
                "token": fcm_token,
                "notification": {"title": title, "body": body},
                "android": {"priority": "high"},
                "apns": {"headers": {"apns-priority": "10"}},
            }
        }
        if data:
            payload["message"]["data"] = {k: str(v) for k, v in data.items()}
        async with httpx.AsyncClient() as client:
            response = await client.post(
                url,
                json=payload,
                headers={
                    "Authorization": f"Bearer {access_token}",
                    "Content-Type": "application/json",
                },
                timeout=10,
            )
            response.raise_for_status()
            return True
    except Exception as exc:
        logger.error(f"FCM send failed: {exc}")
        return False


async def send_booking_status_notification(
    user_fcm: Optional[str],
    provider_fcm: Optional[str],
    booking_id: str,
    new_status: str,
    service_type: str,
) -> None:
    """Send FCM push to both user and provider on booking status change."""
    status_messages: dict[str, tuple[str, str]] = {
        "MATCHED": ("Provider Found! 🎉", f"We matched you with a provider for {service_type}"),
        "CONFIRMED": ("Booking Confirmed ✅", f"Your {service_type} booking is confirmed"),
        "ACCEPTED": ("Provider Accepted 🙌", f"Provider accepted your {service_type} request"),
        "EN_ROUTE": ("On The Way 🚗", f"Your provider is on the way for {service_type}"),
        "IN_PROGRESS": ("Service Started 🔧", f"Your {service_type} service has started"),
        "COMPLETED": ("Service Completed ✅", f"Your {service_type} service is complete. Please review!"),
        "CLOSED": ("Booking Closed 📋", f"Booking for {service_type} has been closed"),
        "DISPUTED": ("Dispute Raised ⚠️", f"A dispute has been raised for {service_type}"),
        "CANCELLED": ("Booking Cancelled ❌", f"Your {service_type} booking was cancelled"),
    }
    title, body = status_messages.get(new_status, ("Booking Update", f"Booking {booking_id} updated to {new_status}"))
    data = {"booking_id": booking_id, "status": new_status}

    tasks = []
    if user_fcm:
        tasks.append(send_push_notification(user_fcm, title, body, data))
    if provider_fcm:
        tasks.append(send_push_notification(provider_fcm, f"[Job] {title}", body, data))
    if tasks:
        await asyncio.gather(*tasks, return_exceptions=True)
