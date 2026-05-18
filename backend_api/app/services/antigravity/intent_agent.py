"""
Intent Agent — multilingual natural-language → structured service intent.

Supports: English, Urdu, Roman Urdu.
Returns clarification prompts when confidence < 0.75.
"""
from __future__ import annotations

import json
import uuid
from typing import Any, Literal, Optional

from pydantic import BaseModel, Field

from app.services.antigravity._base_agent import (
    AntigravityTrace,
    call_gemini,
    mask_pii_in_dict,
    run_with_timeout,
    _try_parse_json,
)

# ──────────────────────────────────────────────────────────────────────────────
# Public schemas
# ──────────────────────────────────────────────────────────────────────────────

class UserContext(BaseModel):
    user_id: str
    city: Optional[str] = None
    past_services: list[str] = Field(default_factory=list)
    preferred_language: Literal["en", "ur", "roman_ur"] = "en"


class IntentRequest(BaseModel):
    text: str = Field(..., min_length=3, max_length=2000)
    lang: Literal["en", "ur", "roman_ur"] = "en"
    user_context: Optional[UserContext] = None


class ExtractedIntent(BaseModel):
    service_type: str
    location: Optional[str] = None
    urgency: Literal["low", "medium", "high"] = "medium"
    time_preference: Optional[str] = None
    budget_sensitivity: Literal["low", "medium", "high"] = "medium"
    specific_requirements: list[str] = Field(default_factory=list)
    detected_language: str = "en"


class IntentResponse(BaseModel):
    intent: Optional[ExtractedIntent] = None
    confidence: float = Field(0.0, ge=0.0, le=1.0)
    clarification_prompts: list[str] = Field(default_factory=list)
    needs_clarification: bool = False
    trace_id: str
    session_id: str


# ──────────────────────────────────────────────────────────────────────────────
# Constants
# ──────────────────────────────────────────────────────────────────────────────

KNOWN_SERVICES = [
    "Plumbing", "Electrical", "Cleaning", "Carpentry", "Painting",
    "AC Repair", "Appliance Repair", "Pest Control", "Gardening",
    "Mason", "Welding", "Glass Fitting", "Waterproofing",
    "Home Shifting", "Deep Cleaning", "Fumigation",
]

CONFIDENCE_THRESHOLD = 0.75

SYSTEM_PROMPT = """You are the Intent Extraction Agent for Ease Home Service, a Pakistani home-services app.

TASK:
Parse the user's natural-language request and extract a structured JSON object.

RULES:
1. Detect the language (en / ur / roman_ur) and respond in the same language for clarification prompts.
2. Map the request to one of these service types: {services}
3. Extract: service_type, location (area/city only — never full address), urgency (low/medium/high),
   time_preference (ASAP / today / tomorrow / specific date-time), budget_sensitivity (low/medium/high),
   specific_requirements (list of strings).
4. Assign a confidence score (0.0 – 1.0).
5. If confidence < 0.75, also return "clarification_prompts": a list of 1-3 short questions to ask the user.

RESPOND WITH STRICT JSON — no markdown fences, no commentary:
{{
  "service_type": "...",
  "location": "...",
  "urgency": "low|medium|high",
  "time_preference": "...",
  "budget_sensitivity": "low|medium|high",
  "specific_requirements": ["..."],
  "detected_language": "en|ur|roman_ur",
  "confidence": 0.0,
  "clarification_prompts": []
}}"""

FALLBACK_RESULT: dict[str, Any] = {
    "service_type": "General",
    "location": None,
    "urgency": "medium",
    "time_preference": None,
    "budget_sensitivity": "medium",
    "specific_requirements": [],
    "detected_language": "en",
    "confidence": 0.0,
    "clarification_prompts": ["Could you describe the service you need?"],
}


# ──────────────────────────────────────────────────────────────────────────────
# Core implementation
# ──────────────────────────────────────────────────────────────────────────────

async def _extract_intent(text: str, lang: str, user_context: dict | None) -> dict:
    system = SYSTEM_PROMPT.format(services=", ".join(KNOWN_SERVICES))
    user_prompt = f"Language: {lang}\nUser request: {text}"
    if user_context:
        safe_ctx = mask_pii_in_dict(user_context)
        user_prompt += f"\nUser context: {json.dumps(safe_ctx)}"

    raw = await call_gemini(system, user_prompt)
    return _try_parse_json(raw)


async def parse_user_intent(request: IntentRequest) -> IntentResponse:
    """
    Public entry point.  Parses a user's natural-language service request
    into a structured intent with confidence scoring and optional
    clarification prompts.
    """
    session_id = str(uuid.uuid4())
    trace = AntigravityTrace(agent_type="intent_agent", session_id=session_id)

    # Populate trace workplan / task_plan
    trace.workplan = "Extract structured service intent from natural language"
    trace.task_plan = mask_pii_in_dict({
        "input_text": request.text,
        "lang": request.lang,
        "has_user_context": request.user_context is not None,
    })

    # Run Gemini with timeout guard
    ctx_dict = request.user_context.model_dump() if request.user_context else None
    parsed = await run_with_timeout(
        _extract_intent(request.text, request.lang, ctx_dict),
        trace=trace,
        fallback_result=FALLBACK_RESULT,
    )

    # Populate remaining trace fields
    confidence = float(parsed.get("confidence", 0.0))
    trace.observations = json.dumps(mask_pii_in_dict(parsed))
    trace.reasoning = (
        f"Detected service_type={parsed.get('service_type')} with confidence={confidence:.2f}. "
        f"Language detected: {parsed.get('detected_language', request.lang)}."
    )
    trace.decisions = {
        "needs_clarification": confidence < CONFIDENCE_THRESHOLD,
        "service_mapped": parsed.get("service_type", "Unknown"),
    }
    trace.action_execution = {"gemini_call": True, "fallback": trace.fallback_triggered}
    trace.confidence = confidence
    trace.final_outcome = json.dumps(mask_pii_in_dict(parsed))

    await trace.persist()

    # Build response
    needs_clarification = confidence < CONFIDENCE_THRESHOLD
    clarification_prompts = parsed.get("clarification_prompts", [])
    if needs_clarification and not clarification_prompts:
        clarification_prompts = [
            "Kya aap bata sakte hain kaunsi service chahiye?" if request.lang in ("ur", "roman_ur")
            else "Could you describe the service you need in more detail?"
        ]

    intent = ExtractedIntent(
        service_type=parsed.get("service_type", "General"),
        location=parsed.get("location"),
        urgency=parsed.get("urgency", "medium"),
        time_preference=parsed.get("time_preference"),
        budget_sensitivity=parsed.get("budget_sensitivity", "medium"),
        specific_requirements=parsed.get("specific_requirements", []),
        detected_language=parsed.get("detected_language", request.lang),
    )

    return IntentResponse(
        intent=intent,
        confidence=confidence,
        clarification_prompts=clarification_prompts,
        needs_clarification=needs_clarification,
        trace_id=trace.trace_id,
        session_id=session_id,
    )
