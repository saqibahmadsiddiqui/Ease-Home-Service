from __future__ import annotations

from app.services.antigravity.intent_agent import _run_agent


async def evaluate_quality(
    booking_id: str,
    provider_id: str,
    review_text: str,
    rating: float,
    session_id: str,
) -> dict:
    """Evaluate service quality, flag anomalies, and update provider score."""
    context = {
        "booking_id": booking_id,
        "provider_id": provider_id,
        "review_text": review_text,
        "rating": rating,
    }
    result = await _run_agent(
        agent_type="quality_agent",
        session_id=session_id,
        prompt=(
            "Evaluate this service review for quality signals. Return JSON with: "
            "sentiment (positive/neutral/negative), is_suspicious (bool), "
            "quality_score (0-100), flag_reason (string or null), "
            "recommended_action (none/review/warn/suspend)."
        ),
        context=context,
    )
    return result
