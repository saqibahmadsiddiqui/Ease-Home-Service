"""
Pricing Agent — full itemised pricing with surge, loyalty, and budget alternative.

Formula:
  FINAL = (BASE_RATE × COMPLEXITY_MULT) + DISTANCE_FEE + URGENCY_PREMIUM
        + SURGE_ADJUSTMENT − LOYALTY_DISCOUNT

Distance fee: PKR 50/km (admin-configurable via settings).
"""
from __future__ import annotations
import json, math, uuid
from typing import Optional
from pydantic import BaseModel, Field
from app.core.config.settings import get_settings
from app.services.antigravity._base_agent import (
    AntigravityTrace, mask_pii_in_dict, run_with_timeout, call_gemini,
)
from app.services.firebase.firestore_service import (
    count_online_providers, count_total_active_providers,
    get_user_booking_count, get_providers_by_skill_and_city,
)

_s = get_settings()

class PriceRequest(BaseModel):
    user_id: str; service_type: str; city: str
    user_lat: float; user_lng: float
    provider_id: str
    provider_lat: float; provider_lng: float
    base_rate: Optional[float] = None
    complexity_multiplier: float = Field(1.0, ge=1.0, le=5.0)
    is_urgent: bool = False
    budget_sensitive: bool = False

class PriceLineItem(BaseModel):
    label: str; amount: float; detail: str = ""

class AlternativeProvider(BaseModel):
    provider_id: str; full_name: str; rate_per_hour: float
    estimated_final: float; distance_km: float

class PriceResponse(BaseModel):
    base_rate: float; complexity_multiplier: float
    distance_km: float; distance_fee: float
    urgency_premium: float; surge_adjustment: float
    loyalty_discount: float; loyalty_tier: int
    final_price: float
    line_items: list[PriceLineItem]
    budget_alternative: Optional[AlternativeProvider] = None
    trace_id: str; session_id: str

def _hav(a1,o1,a2,o2):
    R=6371;p1,p2=math.radians(a1),math.radians(a2)
    dp,dl=math.radians(a2-a1),math.radians(o2-o1)
    a=math.sin(dp/2)**2+math.cos(p1)*math.cos(p2)*math.sin(dl/2)**2
    return 2*R*math.asin(math.sqrt(a))

def _loyalty_tier(bookings:int)->tuple[int,float]:
    if bookings>=_s.LOYALTY_TIER_4_MIN: return 4,_s.LOYALTY_TIER_4_DISCOUNT
    if bookings>=_s.LOYALTY_TIER_3_MIN: return 3,_s.LOYALTY_TIER_3_DISCOUNT
    if bookings>=_s.LOYALTY_TIER_2_MIN: return 2,_s.LOYALTY_TIER_2_DISCOUNT
    if bookings>=_s.LOYALTY_TIER_1_MIN: return 1,_s.LOYALTY_TIER_1_DISCOUNT
    return 0,0.0

async def calculate_price(req: PriceRequest) -> PriceResponse:
    sid=str(uuid.uuid4())
    trace=AntigravityTrace(agent_type="pricing_agent",session_id=sid)
    trace.workplan="Calculate itemised price with surge/loyalty"
    trace.task_plan=mask_pii_in_dict(req.model_dump())

    base=req.base_rate or _s.BASE_RATE_DEFAULT
    dist=round(_hav(req.provider_lat,req.provider_lng,req.user_lat,req.user_lng),2)
    dist_fee=round(dist*_s.DISTANCE_FEE_PER_KM,2)
    urgency=round(base*0.15,2) if req.is_urgent else 0.0

    online=await count_online_providers(req.city)
    total_active=await count_total_active_providers(req.city)
    avail_ratio=online/max(total_active,1)
    surge=round(base*(_s.SURGE_MULTIPLIER-1),2) if avail_ratio<_s.SURGE_THRESHOLD else 0.0

    bookings=await get_user_booking_count(req.user_id)
    tier,disc_pct=_loyalty_tier(bookings)
    subtotal=(base*req.complexity_multiplier)+dist_fee+urgency+surge
    loyalty_disc=round(subtotal*disc_pct,2)
    final=max(round(subtotal-loyalty_disc,2),0)

    trace.tool_calls=[
        {"tool":"firestore.count_online","result":online},
        {"tool":"firestore.count_active","result":total_active},
        {"tool":"firestore.booking_count","result":bookings},
    ]

    items=[
        PriceLineItem(label="Base Rate",amount=base,detail=f"PKR {base}/hr"),
        PriceLineItem(label="Complexity",amount=round(base*(req.complexity_multiplier-1),2),detail=f"×{req.complexity_multiplier}"),
        PriceLineItem(label="Distance",amount=dist_fee,detail=f"{dist}km × PKR {_s.DISTANCE_FEE_PER_KM}/km"),
    ]
    if urgency: items.append(PriceLineItem(label="Urgency Premium",amount=urgency,detail="15% surcharge"))
    if surge: items.append(PriceLineItem(label="Surge",amount=surge,detail=f"Availability {avail_ratio:.0%} < 30%"))
    if loyalty_disc: items.append(PriceLineItem(label="Loyalty Discount",amount=-loyalty_disc,detail=f"Tier {tier} ({disc_pct:.0%})"))
    items.append(PriceLineItem(label="Total",amount=final))

    # Budget alternative
    alt=None
    if req.budget_sensitive:
        cands=await get_providers_by_skill_and_city(req.service_type,req.city)
        cheaper=[c for c in cands if c.get("uid")!=req.provider_id]
        cheaper.sort(key=lambda c: next((s.get("rate_per_hour",9999) for s in c.get("skills",[]) if s.get("skill","").lower()==req.service_type.lower()),9999))
        if cheaper:
            c=cheaper[0]
            cr=next((s.get("rate_per_hour",500) for s in c.get("skills",[]) if s.get("skill","").lower()==req.service_type.lower()),500)
            cl=c.get("location") or {}
            cd=round(_hav(cl.get("latitude",req.user_lat),cl.get("longitude",req.user_lng),req.user_lat,req.user_lng),2)
            cest=round(cr*req.complexity_multiplier+cd*_s.DISTANCE_FEE_PER_KM,2)
            alt=AlternativeProvider(provider_id=c.get("uid",""),full_name=c.get("full_name",""),rate_per_hour=cr,estimated_final=cest,distance_km=cd)

    trace.observations=json.dumps({"dist":dist,"surge":surge>0,"tier":tier})
    trace.reasoning=f"Base PKR {base} × {req.complexity_multiplier} + dist PKR {dist_fee} + urgency PKR {urgency} + surge PKR {surge} − loyalty PKR {loyalty_disc} = PKR {final}"
    trace.confidence=0.95; trace.final_outcome=f"PKR {final}"
    await trace.persist()

    return PriceResponse(base_rate=base,complexity_multiplier=req.complexity_multiplier,distance_km=dist,distance_fee=dist_fee,urgency_premium=urgency,surge_adjustment=surge,loyalty_discount=loyalty_disc,loyalty_tier=tier,final_price=final,line_items=items,budget_alternative=alt,trace_id=trace.trace_id,session_id=sid)
