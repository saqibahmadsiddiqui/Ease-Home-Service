from pydantic_settings import BaseSettings, SettingsConfigDict
from functools import lru_cache
from typing import Literal


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    # App
    APP_NAME: str = "Ease Home Service API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    ENVIRONMENT: Literal["development", "staging", "production"] = "development"
    API_PREFIX: str = "/api/v1"

    # Firebase
    FIREBASE_PROJECT_ID: str
    FIREBASE_CREDENTIALS_PATH: str = "firebase-service-account.json"
    FIREBASE_STORAGE_BUCKET: str
    FIREBASE_WEB_API_KEY: str

    # JWT
    JWT_SECRET_KEY: str
    JWT_ALGORITHM: str = "HS256"
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    JWT_REFRESH_TOKEN_EXPIRE_DAYS: int = 30

    # Admin PIN (hashed)
    ADMIN_PIN_HASH: str

    # Google Cloud / Cloud Run
    GOOGLE_CLOUD_PROJECT: str
    CLOUD_RUN_REGION: str = "us-central1"
    CLOUD_RUN_SERVICE_URL: str = ""

    # Vertex AI / Gemini
    VERTEX_AI_LOCATION: str = "us-central1"
    GEMINI_MODEL: str = "gemini-1.5-flash"
    VERTEX_AI_PROJECT: str = ""

    # Google Maps
    GOOGLE_MAPS_API_KEY: str = ""

    # Pricing defaults
    BASE_RATE_DEFAULT: float = 500.0          # PKR per hour
    SURGE_THRESHOLD: float = 0.30             # 30% provider availability triggers surge
    SURGE_MULTIPLIER: float = 1.25
    DISTANCE_FEE_PER_KM: float = 30.0        # PKR per km

    # Loyalty tiers: (min_bookings, discount_pct)
    LOYALTY_TIER_1_MIN: int = 3
    LOYALTY_TIER_1_DISCOUNT: float = 0.05
    LOYALTY_TIER_2_MIN: int = 7
    LOYALTY_TIER_2_DISCOUNT: float = 0.10
    LOYALTY_TIER_3_MIN: int = 12
    LOYALTY_TIER_3_DISCOUNT: float = 0.15
    LOYALTY_TIER_4_MIN: int = 20
    LOYALTY_TIER_4_DISCOUNT: float = 0.20

    # Firestore collections
    FIRESTORE_USERS_COLLECTION: str = "users"
    FIRESTORE_PROVIDERS_COLLECTION: str = "providers"
    FIRESTORE_BOOKINGS_COLLECTION: str = "bookings"
    FIRESTORE_DISPUTES_COLLECTION: str = "disputes"
    FIRESTORE_REVIEWS_COLLECTION: str = "reviews"
    FIRESTORE_ANTIGRAVITY_LOGS_COLLECTION: str = "antigravity_logs"
    FIRESTORE_RECEIPTS_COLLECTION: str = "receipts"

    # CORS
    ALLOWED_ORIGINS: list[str] = ["*"]


@lru_cache
def get_settings() -> Settings:
    return Settings()
