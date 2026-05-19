"""
Scheduling Agent — double-booking prevention, 30-min travel buffer,
alternate slot suggestions, and waitlist notification.
"""
from __future__ import annotations
import json, uuid
from datetime import datetime, timedelta, timezone
from typing import Optional
from pydantic import BaseModel, Field
from app.services.antigravity._base_agent import (
    AntigravityTrace, mask_pii_in_dict, run_with_timeout,
)
from app.services.firebase.firestore_service import query_collection, create_document
from app.core.config.settings import get_settings

_s = get_settings()
TRAVEL_BUFFER = timedelta(minutes=30)

class SlotRequest(BaseModel):
    provider_id: str; service_type: str
    preferred_start: datetime; estimated_duration_hours: float = Field(1.0, gt=0, le=12)
    user_id: str

class TimeSlot(BaseModel):
    start: datetime; end: datetime; is_available: bool = True

class ScheduleResponse(BaseModel):
    requested_slot: TimeSlot; is_available: bool
    alternate_slots: list[TimeSlot]
    waitlist_id: Optional[str] = None
    trace_id: str; session_id: str

def _slot_end(start: datetime, hours: float) -> datetime:
    return start + timedelta(hours=hours)

async def _get_provider_bookings(provider_id: str, day: datetime) -> list[dict]:
    day_start = day.replace(hour=0, minute=0, second=0, microsecond=0)
    day_end = day_start + timedelta(days=1)
    bookings = await query_collection(
        _s.FIRESTORE_BOOKINGS_COLLECTION,
        filters=[("provider_id", "==", provider_id)],
        limit=50,
    )
    result = []
    for b in bookings:
        s = b.get("scheduled_at")
        if s and b.get("status") not in ("CANCELLED", "CLOSED"):
            try:
                st = datetime.fromisoformat(str(s)) if isinstance(s, str) else s
                if day_start <= st < day_end:
                    result.append(b)
            except (ValueError, TypeError):
                pass
    return result

def _conflicts(existing: list[dict], start: datetime, end: datetime) -> bool:
    for b in existing:
        bs = datetime.fromisoformat(str(b["scheduled_at"])) if isinstance(b["scheduled_at"], str) else b["scheduled_at"]
        dur = b.get("estimated_duration_hours", 1.0)
        be = bs + timedelta(hours=dur) + TRAVEL_BUFFER
        buffered_start = bs - TRAVEL_BUFFER
        if start < be and end > buffered_start:
            return True
    return False

def _suggest_alternates(existing: list[dict], preferred: datetime, duration: float, count: int = 3) -> list[TimeSlot]:
    alts: list[TimeSlot] = []
    for delta_hours in [1, 2, 3, -1, -2, 4, 5, -3]:
        candidate = preferred + timedelta(hours=delta_hours)
        if candidate < datetime.now(timezone.utc):
            continue
        c_end = _slot_end(candidate, duration)
        if not _conflicts(existing, candidate, c_end):
            alts.append(TimeSlot(start=candidate, end=c_end, is_available=True))
            if len(alts) >= count:
                break
    return alts

async def schedule_booking(req: SlotRequest) -> ScheduleResponse:
    sid = str(uuid.uuid4())
    trace = AntigravityTrace(agent_type="scheduling_agent", session_id=sid)
    trace.workplan = f"Check slot availability for provider {req.provider_id}"
    trace.task_plan = mask_pii_in_dict(req.model_dump(mode="json"))

    existing = await _get_provider_bookings(req.provider_id, req.preferred_start)
    trace.tool_calls.append({"tool": "firestore.provider_bookings", "count": len(existing)})

    req_end = _slot_end(req.preferred_start, req.estimated_duration_hours)
    slot = TimeSlot(start=req.preferred_start, end=req_end)
    available = not _conflicts(existing, req.preferred_start, req_end)
    slot.is_available = available

    alts: list[TimeSlot] = []
    waitlist_id: Optional[str] = None

    if not available:
        alts = _suggest_alternates(existing, req.preferred_start, req.estimated_duration_hours)
        # Create waitlist entry
        wl_doc = {
            "user_id": req.user_id, "provider_id": req.provider_id,
            "preferred_start": req.preferred_start.isoformat(),
            "service_type": req.service_type, "status": "waiting",
        }
        waitlist_id = await create_document("waitlist", wl_doc)
        trace.tool_calls.append({"tool": "firestore.create_waitlist", "id": waitlist_id})

    trace.observations = json.dumps({"available": available, "alternates": len(alts), "existing_bookings": len(existing)})
    trace.reasoning = f"Slot {'available' if available else 'blocked'}. {len(existing)} existing bookings checked with 30-min travel buffer."
    trace.decisions = {"booked": available, "alternatives_offered": len(alts), "waitlisted": waitlist_id is not None}
    trace.confidence = 1.0 if available else 0.6
    trace.final_outcome = "SLOT_AVAILABLE" if available else f"BLOCKED — {len(alts)} alternates offered"
    await trace.persist()

    return ScheduleResponse(
        requested_slot=slot, is_available=available,
        alternate_slots=alts, waitlist_id=waitlist_id,
        trace_id=trace.trace_id, session_id=sid,
    )


async def suggest_schedule(
    provider_id: str,
    availability: list[dict],
    requested_at: Optional[str] = None,
    session_id: Optional[str] = None,
) -> dict:
    """
    Suggest available slots for the provider based on their availability profile
    and existing bookings, using travel buffer constraints.
    """
    import logging
    logger = logging.getLogger(__name__)

    sid = session_id or str(uuid.uuid4())
    trace = AntigravityTrace(agent_type="scheduling_agent", session_id=sid)
    trace.workplan = f"Suggest schedule options for provider {provider_id}"
    trace.task_plan = {"provider_id": provider_id, "availability_count": len(availability)}

    # We will look at the next 3 days
    now = datetime.now(timezone.utc)
    suggested_slots = []

    # Map weekday abbreviation
    days_map = {0: "Mon", 1: "Tue", 2: "Wed", 3: "Thu", 4: "Fri", 5: "Sat", 6: "Sun"}

    # Fetch availability slots
    parsed_slots = []
    for slot in availability:
        if isinstance(slot, dict):
            parsed_slots.append(slot)
        else:
            try:
                parsed_slots.append(slot.model_dump())
            except Exception:
                pass

    for i in range(3):
        target_date = now + timedelta(days=i)
        day_name = days_map[target_date.weekday()]
        
        # Existing bookings for this provider on this day
        existing = await _get_provider_bookings(provider_id, target_date)
        trace.tool_calls.append({"tool": "firestore.provider_bookings", "day": day_name, "count": len(existing)})

        # Match slots for this day
        day_slots = [s for s in parsed_slots if s.get("day") == day_name]
        
        if not day_slots:
            # Fallback/default availability if not specified: 09:00 - 17:00
            day_slots = [{"day": day_name, "start_time": "09:00", "end_time": "17:00"}]

        for ds in day_slots:
            try:
                sh, sm = map(int, ds["start_time"].split(":"))
                eh, em = map(int, ds["end_time"].split(":"))
                
                start_dt = target_date.replace(hour=sh, minute=sm, second=0, microsecond=0)
                end_dt = target_date.replace(hour=eh, minute=em, second=0, microsecond=0)
                
                # Check 1-hour slots within this window
                current_slot_start = start_dt
                while current_slot_start + timedelta(hours=1) <= end_dt:
                    slot_end = current_slot_start + timedelta(hours=1)
                    if current_slot_start > now:
                        # Check conflicts
                        if not _conflicts(existing, current_slot_start, slot_end):
                            suggested_slots.append({
                                "start": current_slot_start.isoformat(),
                                "end": slot_end.isoformat(),
                                "is_available": True
                            })
                    current_slot_start += timedelta(hours=1)
            except Exception as e:
                logger.error(f"Error parsing slot {ds}: {e}")

    # Limit to 5 suggested slots
    suggested_slots = suggested_slots[:5]

    trace.observations = json.dumps({"suggested_count": len(suggested_slots)})
    trace.reasoning = f"Generated {len(suggested_slots)} available schedule slots for provider {provider_id} over the next 3 days."
    trace.decisions = {"suggested_slots": len(suggested_slots)}
    trace.confidence = 1.0
    trace.final_outcome = f"SUCCESS — {len(suggested_slots)} slots suggested"
    await trace.persist()

    return {
        "provider_id": provider_id,
        "suggested_slots": suggested_slots,
        "trace_id": trace.trace_id,
    }

