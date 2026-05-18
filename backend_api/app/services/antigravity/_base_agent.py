"""
Antigravity Agent Base — shared infrastructure for all agents.

Provides:
  - PII masking for traces
  - Vertex AI / Gemini invocation with async timeout + fallback
  - Full Antigravity trace schema construction and Firestore persistence
"""
from __future__ import annotations

import asyncio
import json
import logging
import re
import time
import uuid
from datetime import datetime, timezone
from typing import Any, Optional

import vertexai
from vertexai.generative_models import GenerativeModel

from app.core.config.settings import Settings, get_settings
from app.services.firebase.firestore_service import log_antigravity_trace

logger = logging.getLogger(__name__)
_settings = get_settings()

AGENT_TIMEOUT_SECONDS = 10.0


# ──────────────────────────────────────────────────────────────────────────────
# PII Masking
# ──────────────────────────────────────────────────────────────────────────────

_PII_PATTERNS: list[tuple[re.Pattern, str]] = [
    # CNIC: 13-digit or xxxxx-xxxxxxx-x
    (re.compile(r"\b\d{5}-?\d{7}-?\d\b"), "[CNIC_REDACTED]"),
    # Pakistani phone: +92xxxxxxxxxx or 03xxxxxxxxx
    (re.compile(r"(?:\+92|0)\d{10}\b"), "[PHONE_REDACTED]"),
    # Email
    (re.compile(r"[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+"), "[EMAIL_REDACTED]"),
    # Full street addresses (heuristic: house/street/block with numbers)
    (re.compile(
        r"\b\d{1,5}\s*[-/]?\s*[A-Za-z]?\s*,?\s*(Street|St|Block|Sector|Phase|Road|Rd|Avenue|Ave|Lane|Gali|Mohalla)\b",
        re.IGNORECASE,
    ), "[ADDRESS_REDACTED]"),
]


def mask_pii(text: str) -> str:
    """Strip CNIC, phone, email, and street-level addresses from a string."""
    for pattern, replacement in _PII_PATTERNS:
        text = pattern.sub(replacement, text)
    return text


def mask_pii_in_dict(data: Any) -> Any:
    """Recursively mask PII in dicts, lists, and strings."""
    if isinstance(data, str):
        return mask_pii(data)
    if isinstance(data, dict):
        return {k: mask_pii_in_dict(v) for k, v in data.items()}
    if isinstance(data, list):
        return [mask_pii_in_dict(item) for item in data]
    return data


# ──────────────────────────────────────────────────────────────────────────────
# Vertex AI Gemini wrapper
# ──────────────────────────────────────────────────────────────────────────────

_vertex_initialised = False


def _ensure_vertex() -> None:
    global _vertex_initialised
    if not _vertex_initialised:
        vertexai.init(
            project=_settings.VERTEX_AI_PROJECT or _settings.GOOGLE_CLOUD_PROJECT,
            location=_settings.VERTEX_AI_LOCATION,
        )
        _vertex_initialised = True


async def call_gemini(system_prompt: str, user_prompt: str) -> str:
    """Call Gemini via Vertex AI and return the raw text response."""
    _ensure_vertex()
    model = GenerativeModel(
        _settings.GEMINI_MODEL,
        system_instruction=[system_prompt],
    )
    response = await model.generate_content_async(user_prompt)
    return response.text


def _try_parse_json(text: str) -> dict:
    """Best-effort JSON extraction from LLM output (handles markdown fences)."""
    cleaned = text.strip()
    # Strip markdown code fences
    if cleaned.startswith("```"):
        lines = cleaned.split("\n")
        lines = [l for l in lines if not l.strip().startswith("```")]
        cleaned = "\n".join(lines).strip()
    try:
        return json.loads(cleaned)
    except json.JSONDecodeError:
        # Try extracting first JSON object
        match = re.search(r"\{[\s\S]*\}", cleaned)
        if match:
            try:
                return json.loads(match.group())
            except json.JSONDecodeError:
                pass
    return {"raw_text": text}


# ──────────────────────────────────────────────────────────────────────────────
# Antigravity Trace builder
# ──────────────────────────────────────────────────────────────────────────────

class AntigravityTrace:
    """Mutable trace object — agents populate fields, then call .persist()."""

    def __init__(self, agent_type: str, session_id: str) -> None:
        self.trace_id: str = str(uuid.uuid4())
        self.agent_type: str = agent_type
        self.session_id: str = session_id
        self._start: float = time.monotonic()

        # Trace fields (all required by schema)
        self.workplan: str = ""
        self.task_plan: dict = {}
        self.observations: str = ""
        self.reasoning: str = ""
        self.tool_calls: list[dict] = []
        self.decisions: dict = {}
        self.action_execution: dict = {}
        self.error_recovery: Optional[str] = None
        self.final_outcome: str = ""
        self.confidence: float = 0.0
        self.cost_usd: float = 0.0
        self.fallback_triggered: bool = False

    @property
    def latency_ms(self) -> int:
        return int((time.monotonic() - self._start) * 1000)

    def to_dict(self) -> dict:
        return mask_pii_in_dict({
            "trace_id": self.trace_id,
            "agent_type": self.agent_type,
            "session_id": self.session_id,
            "workplan": self.workplan,
            "task_plan": self.task_plan,
            "observations": self.observations,
            "reasoning": self.reasoning,
            "tool_calls": self.tool_calls,
            "decisions": self.decisions,
            "action_execution": self.action_execution,
            "error_recovery": self.error_recovery,
            "final_outcome": self.final_outcome,
            "confidence": self.confidence,
            "latency_ms": self.latency_ms,
            "cost_usd": self.cost_usd,
            "fallback_triggered": self.fallback_triggered,
            "timestamp": datetime.now(timezone.utc).isoformat(),
        })

    async def persist(self) -> str:
        """Write this trace to Firestore and return the document ID."""
        doc_id = await log_antigravity_trace(self.to_dict())
        logger.info(
            "Trace persisted  agent=%s  trace=%s  latency=%dms  confidence=%.2f  fallback=%s",
            self.agent_type, self.trace_id, self.latency_ms, self.confidence, self.fallback_triggered,
        )
        return doc_id


# ──────────────────────────────────────────────────────────────────────────────
# Timeout-guarded agent call
# ──────────────────────────────────────────────────────────────────────────────

async def run_with_timeout(
    coro,
    trace: AntigravityTrace,
    fallback_result: dict,
    timeout: float = AGENT_TIMEOUT_SECONDS,
) -> dict:
    """
    Await *coro* with a timeout.  If it exceeds *timeout* seconds, return
    *fallback_result* and mark FALLBACK_TRIGGERED on the trace.
    """
    try:
        return await asyncio.wait_for(coro, timeout=timeout)
    except asyncio.TimeoutError:
        trace.fallback_triggered = True
        trace.error_recovery = f"TIMEOUT after {timeout}s — returning cached/fallback result"
        logger.warning("Agent %s timed out after %.1fs", trace.agent_type, timeout)
        return fallback_result
    except Exception as exc:
        trace.error_recovery = f"Exception: {type(exc).__name__}: {exc}"
        logger.error("Agent %s error: %s", trace.agent_type, exc, exc_info=True)
        return fallback_result
