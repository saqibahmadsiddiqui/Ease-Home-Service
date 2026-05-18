# Ease Home Service — Backend API

FastAPI (Python 3.11) backend powering the Ease Home Service mobile application.

## Quick Start

```bash
# 1. Create virtual environment
python -m venv .venv
.venv\Scripts\activate   # Windows
source .venv/bin/activate  # Linux/Mac

# 2. Install dependencies
pip install -r requirements.txt

# 3. Configure environment
cp .env.example .env
# Fill in all values in .env

# 4. Add Firebase service account
# Download firebase-service-account.json from Firebase Console
# → Project Settings → Service accounts → Generate new private key

# 5. Run locally
uvicorn app.main:app --reload --port 8000
```

Open: http://localhost:8000/docs (Swagger UI — dev mode only)

## Project Structure

```
backend_api/
├── app/
│   ├── main.py                          # FastAPI app factory + lifespan
│   ├── api/routes/
│   │   ├── auth.py                      # POST /auth/*
│   │   ├── bookings.py                  # POST/GET/PATCH /bookings/*
│   │   ├── ai_routes.py                 # POST /ai/*
│   │   ├── provider.py                  # GET/PATCH /provider/*
│   │   └── admin.py                     # GET/POST/PATCH /admin/*
│   ├── core/
│   │   ├── config/settings.py           # Pydantic settings (env-driven)
│   │   └── security/firebase_auth.py    # JWT + role guards
│   ├── models/
│   │   ├── user.py | provider.py | booking.py | dispute.py | review.py
│   ├── services/
│   │   ├── firebase/
│   │   │   ├── firestore_service.py     # Async Firestore CRUD
│   │   │   ├── fcm_service.py           # Push notifications
│   │   │   └── storage_service.py       # File uploads
│   │   └── antigravity/
│   │       ├── intent_agent.py          # NL → structured intent
│   │       ├── matching_agent.py        # Provider scoring & selection
│   │       ├── pricing_agent.py         # Full pricing formula
│   │       ├── scheduling_agent.py      # Slot suggestion
│   │       ├── dispute_agent.py         # AI dispute analysis
│   │       ├── quality_agent.py         # Review quality evaluation
│   │       └── notification_agent.py    # AI-personalised FCM
│   └── tests/test_api.py
├── requirements.txt
├── Dockerfile
└── .env.example
```

## Booking State Machine

```
PENDING → MATCHED → CONFIRMED → ACCEPTED → EN_ROUTE → IN_PROGRESS → COMPLETED → CLOSED
                                                                    ↘ DISPUTED ↗
```
FCM push notification sent to both user and provider at every state transition.
Receipt auto-generated in Firestore when state reaches **CLOSED**.

## Pricing Formula

```
FINAL_PRICE = (BASE_RATE × COMPLEXITY_MULT)
            + DISTANCE_FEE
            + URGENCY_PREMIUM
            + SURGE_ADJUSTMENT
            − LOYALTY_DISCOUNT
```

| Loyalty Tier | Min Bookings | Discount |
|---|---|---|
| 1 | 3+ | 5% |
| 2 | 7+ | 10% |
| 3 | 12+ | 15% |
| 4 | 20+ | 20% |

Surge activates when provider availability < 30% (adds 25% on base rate).

## Antigravity Trace Schema

Every AI agent call is logged to the `antigravity_logs` Firestore collection:

| Field | Type | Description |
|---|---|---|
| agent_type | str | Name of the Antigravity agent |
| session_id | str | Booking / chat session UUID |
| workplan | str | The prompt / task |
| task_plan | dict | Input context |
| observations | str | Raw LLM response |
| reasoning | str | Extracted reasoning |
| tool_calls | list | External tools invoked |
| decisions | dict | Parsed decisions |
| action_execution | dict | Actions taken |
| error_recovery | str? | Error details if any |
| final_outcome | str | Final result |
| confidence | float | 0.0 – 1.0 |
| latency_ms | int | Response time |
| cost_usd | float | API cost |

## Deployment (Cloud Run)

```bash
# Build and push
docker build -t gcr.io/YOUR_PROJECT/ease-home-api .
docker push gcr.io/YOUR_PROJECT/ease-home-api

# Deploy
gcloud run deploy ease-home-service-api \
  --image gcr.io/YOUR_PROJECT/ease-home-api \
  --platform managed --region us-central1 \
  --allow-unauthenticated
```

CI/CD pipeline auto-deploys on push to `main` via `.github/workflows/ci_cd.yml`.
