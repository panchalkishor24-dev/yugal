# Yugal — backend & deployment architecture (plan)

## Services
- **API**: Node.js + Express (TypeScript), REST `/v1`, JWT access + rotating refresh tokens.
- **Realtime**: WebSocket gateway (chat, typing, read receipts, presence) with Redis pub/sub for fan-out.
- **DB**: PostgreSQL 16 + PostGIS (geo discovery). **Redis**: sessions, rate limits, daily-likes counters, presence, queues (BullMQ).
- **Media**: S3-compatible bucket + CDN; signed upload URLs; async moderation pipeline.
- **Workers**: daily curated matches, boost expiry, moderation, subscription reconciliation, notifications (FCM).
- **Calls**: WebRTC with a managed SFU/TURN provider (LiveKit/Twilio/Agora).
- **AI**: backend-only calls to the LLM; content moderation before and after generation; per-user rate limits.

## Core schema (PostgreSQL)
```sql
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone TEXT UNIQUE, email TEXT UNIQUE,
  auth_provider TEXT NOT NULL DEFAULT 'phone',
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','suspended','deleted')),
  confirmed_18_plus BOOLEAN NOT NULL DEFAULT false,
  language TEXT NOT NULL DEFAULT 'en',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE profiles (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL, dob DATE NOT NULL, gender TEXT, bio TEXT,
  occupation TEXT, education TEXT, income_range TEXT,
  religion TEXT, caste TEXT, community TEXT,
  diet TEXT, smoking TEXT, drinking TEXT,
  height_cm INT, weight_kg INT, fitness TEXT,
  goals TEXT[] NOT NULL DEFAULT '{}', interests TEXT[] NOT NULL DEFAULT '{}',
  city TEXT, location GEOGRAPHY(Point, 4326),
  authenticity_score INT NOT NULL DEFAULT 40,
  incognito BOOLEAN NOT NULL DEFAULT false
);
CREATE INDEX profiles_location_gix ON profiles USING GIST (location);

CREATE TABLE media (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  kind TEXT NOT NULL CHECK (kind IN ('photo','video')),
  url TEXT NOT NULL, position INT NOT NULL DEFAULT 0,
  moderation_status TEXT NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE verifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('selfie','govt_id','linkedin')),
  status TEXT NOT NULL DEFAULT 'pending',
  provider_ref TEXT, reviewed_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE swipes (
  swiper_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  target_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  action TEXT NOT NULL CHECK (action IN ('like','pass','super')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (swiper_id, target_id)
);

CREATE TABLE matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_a UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_b UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (user_a < user_b), UNIQUE (user_a, user_b)
);

CREATE TABLE messages (
  id BIGSERIAL PRIMARY KEY,
  match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES users(id),
  kind TEXT NOT NULL DEFAULT 'text' CHECK (kind IN ('text','voice','image','video')),
  body TEXT, media_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  delivered_at TIMESTAMPTZ, read_at TIMESTAMPTZ
);
CREATE INDEX messages_match_idx ON messages (match_id, id DESC);

CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  plan TEXT NOT NULL CHECK (plan IN ('premium','vip')),
  status TEXT NOT NULL, current_period_end TIMESTAMPTZ,
  provider_subscription_id TEXT
);

CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  kind TEXT NOT NULL,                 -- plan | boost | super_likes | badge | featured
  amount_paise INT NOT NULL,
  provider_order_id TEXT UNIQUE, provider_payment_id TEXT,
  status TEXT NOT NULL DEFAULT 'created',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID NOT NULL REFERENCES users(id),
  target_id UUID NOT NULL REFERENCES users(id),
  reason TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'open',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE blocks (
  blocker_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  blocked_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  PRIMARY KEY (blocker_id, blocked_id)
);
```

## API surface (`/v1`)
| Group | Endpoints |
|---|---|
| Auth | `POST /auth/otp/request`, `/auth/otp/verify`, `/auth/social`, `/auth/refresh`, `DELETE /me` |
| Profile | `GET/PATCH /me`, `POST /me/media` (signed URL), `POST /me/verify/{selfie,id,linkedin}` |
| Discovery | `GET /discover?mode=for_you\|nearby\|trending\|new`, `GET /daily-matches`, `POST /swipes`, `POST /swipes/rewind` |
| Likes | `GET /likes/received` (premium gets full list) |
| Chat | `GET /matches`, `GET /matches/:id/messages`, WebSocket `wss://…/ws` (send, typing, read) |
| Calls | `POST /calls` → WebRTC token |
| AI | `POST /ai/bio`, `/ai/coach`, `/ai/icebreakers`, `/ai/compat/:userId`, `/ai/photo-check` |
| Safety | `POST /reports`, `POST/DELETE /blocks/:id`, `POST /sos` |
| Payments | `POST /payments/orders`, `POST /payments/webhook` (signature-verified), `GET /subscription` |
| Admin | `/admin/users`, `/admin/verifications`, `/admin/reports`, `/admin/analytics`, `/admin/revenue`, `/admin/fraud` |

## Matching
Hard filters (age, distance, religion/diet if set) → candidate pool from PostGIS → score =
weighted sum of: shared interests, goals alignment, lifestyle (diet/smoking/drinking),
personality-quiz similarity, activity recency, profile quality → rerank for diversity →
cache the daily batch per user in Redis. LLM is used only for *explanations* of the score.

## Security & privacy (India)
- TLS everywhere; encrypt PII at rest; ID documents in a separate encrypted store with short retention.
- Follow the **DPDP Act 2023**: explicit consent, purpose limitation, data-erasure flow, grievance officer.
- Treat religion, caste, income and sexual orientation as sensitive: optional, never used for ads.
- OTP rate limiting + device fingerprinting; refresh-token rotation; RBAC + audit log for staff.
- Server-side verification of every payment webhook; idempotency keys on order creation.
- Moderation: image/text classifiers on upload and on messages; human review queue for flagged items.

## Deployment
- Containers on AWS (ap-south-1 Mumbai) ECS/Fargate or GKE: `api`, `ws`, `worker`.
- RDS PostgreSQL (Multi-AZ) + ElastiCache Redis + S3 + CloudFront.
- CI/CD: GitHub Actions → build image → migrate DB → blue/green deploy.
- Observability: Sentry (app + API), Prometheus/Grafana or CloudWatch, structured logs, uptime alerts.
- Scale path: split `ws` gateway, add read replicas, move feed ranking to a dedicated service.
