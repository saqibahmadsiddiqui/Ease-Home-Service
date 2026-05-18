"""
Matching Agent — 10-factor provider ranking with AI explanation.

Factors (weights total 100):
  rating(15) distance(15) experience(10) on_time_rate(10)
  response_rate(10) job_completion_rate(10) skills_match(10)
  availability_match(5) price_fit(10) review_recency(5)
"""
from __future__ import annotations
import json, math, uuid
from datetime import datetime, timezone
from typing import Any, Optional
from pydantic import BaseModel, Field
from app.services.antigravity._base_agent import (
    AntigravityTrace, call_gemini, mask_pii_in_dict, run_with_timeout, _try_parse_json,
)
from app.services.firebase.firestore_service import get_providers_by_skill_and_city

class MatchRequest(BaseModel):
    service_type: str; city: str
    user_lat: float = Field(..., ge=-90, le=90)
    user_lng: float = Field(..., ge=-180, le=180)
    urgency: str = "medium"; budget_sensitivity: str = "medium"
    max_results: int = Field(5, ge=1, le=20)

class FactorScore(BaseModel):
    factor: str; raw_value: float; weight: int; weighted_score: float

class ScoredProvider(BaseModel):
    provider_id: str; full_name: str; match_score: float
    factors: list[FactorScore]; distance_km: float
    rate_per_hour: Optional[float] = None; rating: float = 0.0
    total_reviews: int = 0; is_online: bool = False

class MatchResponse(BaseModel):
    providers: list[ScoredProvider]; ai_explanation: str
    trace_id: str; session_id: str

WEIGHTS = {"rating":15,"distance":15,"experience":10,"on_time_rate":10,
           "response_rate":10,"job_completion_rate":10,"skills_match":10,
           "availability_match":5,"price_fit":10,"review_recency":5}

def _hav(lat1,lon1,lat2,lon2):
    R=6371.0;p1,p2=math.radians(lat1),math.radians(lat2)
    dp,dl=math.radians(lat2-lat1),math.radians(lon2-lon1)
    a=math.sin(dp/2)**2+math.cos(p1)*math.cos(p2)*math.sin(dl/2)**2
    return 2*R*math.asin(math.sqrt(a))

def _score(p,svc,ulat,ulng,bsens):
    loc=p.get("location") or {}
    plat,plng=loc.get("latitude",ulat),loc.get("longitude",ulng)
    dist=_hav(ulat,ulng,plat,plng)
    cov=p.get("coverage_radius_km",15.0)
    if dist>cov*1.2: return -1,[],dist
    raw={
        "rating": p.get("rating",0)/5.0,
        "distance": max(0,1-dist/max(cov,1)),
        "experience": min(p.get("experience_years",0)/15,1),
        "on_time_rate": p.get("on_time_rate",80)/100,
        "response_rate": p.get("response_rate",70)/100,
        "job_completion_rate": p.get("total_jobs_completed",0)/max(p.get("total_jobs_assigned",1),1),
        "skills_match": 1.0 if svc.lower() in [s.get("skill","").lower() for s in p.get("skills",[])] else 0.3,
        "availability_match": 1.0 if p.get("is_online") else 0.3,
        "price_fit": max(0,1-next((s.get("rate_per_hour",500) for s in p.get("skills",[]) if s.get("skill","").lower()==svc.lower()),500)/(3000 if bsens!="high" else 2000)),
        "review_recency": 0.5,
    }
    factors=[]
    total=0.0
    for f,w in WEIGHTS.items():
        ws=round(raw[f]*w,2); total+=ws
        factors.append(FactorScore(factor=f,raw_value=round(raw[f],3),weight=w,weighted_score=ws))
    return round(total,2),factors,round(dist,2)

async def match_providers(request: MatchRequest) -> MatchResponse:
    sid=str(uuid.uuid4())
    trace=AntigravityTrace(agent_type="matching_agent",session_id=sid)
    trace.workplan=f"Rank providers for {request.service_type} in {request.city}"
    trace.task_plan=mask_pii_in_dict(request.model_dump())
    cands=await get_providers_by_skill_and_city(request.service_type,request.city)
    trace.tool_calls.append({"tool":"firestore.get_providers","count":len(cands)})
    scored=[]
    for c in cands:
        s,f,d=_score(c,request.service_type,request.user_lat,request.user_lng,request.budget_sensitivity)
        if s>=0: scored.append((s,f,d,c))
    scored.sort(key=lambda x:x[0],reverse=True)
    result=[]
    for s,f,d,c in scored[:request.max_results]:
        sr=next((sk.get("rate_per_hour") for sk in c.get("skills",[]) if sk.get("skill","").lower()==request.service_type.lower()),None)
        result.append(ScoredProvider(provider_id=c.get("uid",""),full_name=c.get("full_name",""),match_score=s,factors=f,distance_km=d,rate_per_hour=sr,rating=c.get("rating",0),total_reviews=c.get("total_reviews",0),is_online=c.get("is_online",False)))
    expl="No providers matched." if not result else f"We recommend {result[0].full_name} — rated {result[0].rating:.1f}★, {result[0].distance_km:.1f}km away."
    if result:
        try:
            raw=await run_with_timeout(call_gemini("Generate a 2-sentence friendly recommendation explanation.",json.dumps({"name":result[0].full_name,"score":result[0].match_score,"factors":[f.model_dump() for f in result[0].factors[:3]]})),trace=trace,fallback_result=expl)
            if isinstance(raw,str): expl=raw
        except Exception: pass
    trace.observations=f"{len(cands)} candidates, {len(result)} returned"
    trace.confidence=round(result[0].match_score/100,2) if result else 0.0
    trace.final_outcome=json.dumps(mask_pii_in_dict({"top":[p.provider_id for p in result]}))
    await trace.persist()
    return MatchResponse(providers=result,ai_explanation=expl,trace_id=trace.trace_id,session_id=sid)
