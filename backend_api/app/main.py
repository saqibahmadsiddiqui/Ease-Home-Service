from __future__ import annotations

import logging
from contextlib import asynccontextmanager
from typing import AsyncGenerator

import firebase_admin
from firebase_admin import credentials
from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.core.config.settings import get_settings
from app.api.routes import auth, ai_routes, bookings, provider, admin

logger = logging.getLogger(__name__)
_settings = get_settings()


# ---------------------------------------------------------------------------
# Lifespan: initialise Firebase Admin SDK on startup
# ---------------------------------------------------------------------------

@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    # Startup
    if not firebase_admin._apps:
        try:
            cred = credentials.Certificate(_settings.FIREBASE_CREDENTIALS_PATH)
            firebase_admin.initialize_app(cred, {
                "storageBucket": _settings.FIREBASE_STORAGE_BUCKET,
                "projectId": _settings.FIREBASE_PROJECT_ID,
            })
            logger.info("Firebase Admin SDK initialized ✅")
        except Exception as exc:
            logger.error(f"Firebase init failed: {exc}")
    yield
    # Shutdown (no teardown needed for Firebase)
    logger.info("Ease Home Service API shutting down.")


# ---------------------------------------------------------------------------
# App factory
# ---------------------------------------------------------------------------

def create_app() -> FastAPI:
    app = FastAPI(
        title=_settings.APP_NAME,
        version=_settings.APP_VERSION,
        description="Backend API for Ease Home Service — Ab ghar ka kaam hua asaan",
        docs_url="/docs" if _settings.DEBUG else None,
        redoc_url="/redoc" if _settings.DEBUG else None,
        lifespan=lifespan,
    )

    # CORS
    app.add_middleware(
        CORSMiddleware,
        allow_origins=_settings.ALLOWED_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Global exception handler
    @app.exception_handler(Exception)
    async def global_exception_handler(request: Request, exc: Exception) -> JSONResponse:
        logger.error(f"Unhandled error on {request.url}: {exc}", exc_info=True)
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={"detail": "Internal server error"},
        )

    # Health check
    @app.get("/health", tags=["Health"])
    async def health_check() -> dict:
        return {"status": "ok", "app": _settings.APP_NAME, "version": _settings.APP_VERSION}

    # Register routers
    prefix = _settings.API_PREFIX
    app.include_router(auth.router, prefix=prefix)
    app.include_router(bookings.router, prefix=prefix)
    app.include_router(ai_routes.router, prefix=prefix)
    app.include_router(provider.router, prefix=prefix)
    app.include_router(admin.router, prefix=prefix)

    return app


app = create_app()
