"""
Dispute Agent — auto-classify, AI resolution workflow, blacklist triggers.

Types: NO_SHOW | QUALITY_ISSUE | PRICE_DISPUTE | DAMAGE_CLAIM | OVERRUN | CANCELLATION
Resolutions: FULL_REFUND | PARTIAL_REFUND | WARNING | BLACKLIST | HUMAN_ESCALATION
Auto-escalate after 24h unresolved.
Blacklist: 3 NO_SHOWs OR 2 DAMAGE_CLAIMs in 90 days.
"""
from __future__ import annotations
import json, uuid
from datetime import datetime, timedelta, timezone
from enum import Enum
from typing import Optional
from pydantic import BaseModel, Field
from app.services.antigravity._base_agent import (
    AntigravityTrace, call_gemini, mask_pii_in_dict,
    run_with_timeout, _try_parse_json,
)
from app.services.firebase.firestore_service import (
    create_document, get_document, query_collection, update_document,
)
from app.core.config.settings import get_settings

_s = get_settings()

class DisputeType(str, Enum):
    NO_SHOW = "NO_SHOW"; QUALITY_ISSUE = "QUALITY_ISSUE"
    PRICE_DISPUTE = "PRICE_DISPUTE"; DAMAGE_CLAIM = "DAMAGE_CLAIM"
    OVERRUN = "OVERRUN"; CANCELLATION = "CANCELLATION"

class Resolution(str, Enum):
    FULL_REFUND = "FULL_REFUND"; PARTIAL_REFUND = "PARTIAL_REFUND"
    WARNING = "WARNING"; BLACKLIST = "BLACKLIST"
    HUMAN_ESCALATION = "HUMAN_ESCALATION"

class DisputeRequest(BaseModel):
    booking_id: str; raised_by: str  # "user" or "provider"
    reason: str = Field(..., min_length=10, max_length=2000)
    evidence_urls: list[str] = Field(default_factory=list)

class DisputeAnalysis(BaseModel):
    dispute_type: DisputeType
    resolution: Resolution; confidence: float
    reasoning: str; refund_percentage: float = 0.0
    should_blacklist: bool = False; escalated: bool = False
    trace_id: str; session_id: str

CLASSIFY_SYSTEM = """You are the Dispute Classification Agent for Ease Home Service.
Given a dispute reason, classify it and recommend a resolution.

Dispute types: NO_SHOW, QUALITY_ISSUE, PRICE_DISPUTE, DAMAGE_CLAIM, OVERRUN, CANCELLATION
Resolutions: FULL_REFUND, PARTIAL_REFUND, WARNING, BLACKLIST, HUMAN_ESCALATION

Rules:
- NO_SHOW → FULL_REFUND (confidence >= 0.9)
- DAMAGE_CLAIM → HUMAN_ESCALATION unless clear evidence
- QUALITY_ISSUE with evidence → PARTIAL_REFUND (30-70%)
- PRICE_DISPUTE → review breakdown → WARNING or PARTIAL_REFUND
- OVERRUN → PARTIAL_REFUND 20% if provider at fault
- CANCELLATION by user < 1h → WARNING; by provider → FULL_REFUND

Return strict JSON:
{"dispute_type":"...","resolution":"...","confidence":0.0,"reasoning":"...","refund_percentage":0}"""

FALLBACK = {"dispute_type":"QUALITY_ISSUE","resolution":"HUMAN_ESCALATION",
            "confidence":0.3,"reasoning":"Could not classify — escalating","refund_percentage":0}

async def _check_blacklist(provider_id: str) -> bool:
    cutoff = (datetime.now(timezone.utc) - timedelta(days=90)).isoformat()
    disputes = await query_collection(
        _s.FIRESTORE_DISPUTES_COLLECTION,
        filters=[("provider_id", "==", provider_id)],
        limit=100,
    )
    recent = [d for d in disputes if str(d.get("created_at","")) >= cutoff]
    no_shows = sum(1 for d in recent if d.get("dispute_type") == "NO_SHOW")
    damages = sum(1 for d in recent if d.get("dispute_type") == "DAMAGE_CLAIM")
    return no_shows >= 3 or damages >= 2

async def _should_escalate(dispute_id: str) -> bool:
    doc = await get_document(_s.FIRESTORE_DISPUTES_COLLECTION, dispute_id)
    if not doc:
        return False
    created = doc.get("created_at")
    if isinstance(created, str):
        created = datetime.fromisoformat(created)
    if created and (datetime.now(timezone.utc) - created) > timedelta(hours=24):
        if doc.get("status") in ("OPEN", "UNDER_REVIEW"):
            return True
    return False

async def analyze_dispute(req: DisputeRequest) -> DisputeAnalysis:
    sid = str(uuid.uuid4())
    trace = AntigravityTrace(agent_type="dispute_agent", session_id=sid)
    trace.workplan = f"Classify and resolve dispute for booking {req.booking_id}"
    trace.task_plan = mask_pii_in_dict(req.model_dump())

    # Fetch booking context
    booking = await get_document(_s.FIRESTORE_BOOKINGS_COLLECTION, req.booking_id)
    trace.tool_calls.append({"tool": "firestore.get_booking", "found": booking is not None})
    provider_id = (booking or {}).get("provider_id", "")
    user_id = (booking or {}).get("user_id", "")

    # AI classification with timeout
    prompt = json.dumps(mask_pii_in_dict({
        "reason": req.reason,
        "evidence_count": len(req.evidence_urls),
        "raised_by": req.raised_by,
        "booking_status": (booking or {}).get("status", "UNKNOWN"),
    }))
    raw = await run_with_timeout(
        call_gemini(CLASSIFY_SYSTEM, prompt),
        trace=trace, fallback_result=json.dumps(FALLBACK),
    )
    if isinstance(raw, str):
        parsed = _try_parse_json(raw)
    else:
        parsed = raw
    trace.tool_calls.append({"tool": "gemini.classify", "success": "dispute_type" in parsed})

    dtype = parsed.get("dispute_type", "QUALITY_ISSUE")
    resolution = parsed.get("resolution", "HUMAN_ESCALATION")
    confidence = float(parsed.get("confidence", 0.3))
    reasoning = parsed.get("reasoning", "")
    refund_pct = float(parsed.get("refund_percentage", 0))

    # Blacklist check
    should_blacklist = False
    if provider_id:
        should_blacklist = await _check_blacklist(provider_id)
        trace.tool_calls.append({"tool": "blacklist_check", "result": should_blacklist})
        if should_blacklist:
            resolution = "BLACKLIST"
            await update_document(_s.FIRESTORE_PROVIDERS_COLLECTION, provider_id, {
                "is_active": False, "is_blacklisted": True,
            })

    # Store dispute
    dispute_doc = {
        "booking_id": req.booking_id, "user_id": user_id,
        "provider_id": provider_id, "raised_by": req.raised_by,
        "reason": req.reason, "evidence_urls": req.evidence_urls,
        "dispute_type": dtype, "resolution": resolution,
        "refund_percentage": refund_pct,
        "ai_confidence": confidence, "ai_reasoning": reasoning,
        "status": "UNDER_REVIEW", "should_blacklist": should_blacklist,
    }
    dispute_id = await create_document(_s.FIRESTORE_DISPUTES_COLLECTION, dispute_doc)
    trace.tool_calls.append({"tool": "firestore.create_dispute", "id": dispute_id})

    # Auto-escalate check
    escalated = False
    if confidence < 0.5 or resolution == "HUMAN_ESCALATION":
        escalated = True
        await update_document(_s.FIRESTORE_DISPUTES_COLLECTION, dispute_id, {"status": "ESCALATED"})

    trace.observations = json.dumps(mask_pii_in_dict(parsed))
    trace.reasoning = reasoning
    trace.decisions = {"type": dtype, "resolution": resolution, "blacklist": should_blacklist, "escalated": escalated}
    trace.confidence = confidence
    trace.final_outcome = f"{dtype} → {resolution}"
    await trace.persist()

    return DisputeAnalysis(
        dispute_type=DisputeType(dtype), resolution=Resolution(resolution),
        confidence=confidence, reasoning=reasoning,
        refund_percentage=refund_pct, should_blacklist=should_blacklist,
        escalated=escalated, trace_id=trace.trace_id, session_id=sid,
    )
