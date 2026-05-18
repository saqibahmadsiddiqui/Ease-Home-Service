from __future__ import annotations

from app.services.antigravity.intent_agent import _run_agent
from app.services.firebase.fcm_service import send_push_notification


async def generate_smart_notification(
    event_type: str,
    user_id: str,
    fcm_token: str,
    context: dict,
    session_id: str,
) -> bool:
    """Generate a personalized push notification using AI and send it."""
    result = await _run_agent(
        agent_type="notification_agent",
        session_id=session_id,
        prompt=(
            f"Generate a short, engaging push notification for the event '{event_type}'. "
            "Return JSON with: title (max 50 chars), body (max 100 chars), emoji_prefix (1-2 emojis)."
        ),
        context={**context, "user_id": user_id, "event_type": event_type},
    )
    # Fallback notification if AI fails
    title = f"Update: {event_type}"
    body = "You have a new update on Ease Home Service."
    return await send_push_notification(fcm_token, title, body, {"event": event_type})
