from __future__ import annotations

import pytest
from httpx import AsyncClient, ASGITransport
from unittest.mock import AsyncMock, patch

from app.main import app


@pytest.fixture
def anyio_backend():
    return "asyncio"


@pytest.fixture
async def client():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        yield ac


@pytest.mark.anyio
async def test_health_check(client: AsyncClient):
    response = await client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert "version" in data


@pytest.mark.anyio
async def test_protected_route_without_token(client: AsyncClient):
    response = await client.get("/api/v1/auth/me")
    assert response.status_code == 401  # No token → 401



@pytest.mark.anyio
async def test_booking_requires_auth(client: AsyncClient):
    response = await client.post("/api/v1/bookings/", json={
        "service_type": "Plumbing",
        "description": "Fix leaking pipe under kitchen sink",
        "location": {
            "address": "123 Main St, Lahore",
            "latitude": 31.5204,
            "longitude": 74.3587,
            "city": "Lahore",
        },
        "is_urgent": False,
    })
    assert response.status_code in (401, 403)


@pytest.mark.anyio
async def test_admin_sign_in_wrong_pin(client: AsyncClient):
    with patch("app.api.routes.auth.verify_pin", return_value=False):
        response = await client.post("/api/v1/auth/admin/sign-in", json={
            "email": "admin@easehome.com",
            "password": "TestPass123",
            "pin": "0000",
        })
    assert response.status_code == 401
