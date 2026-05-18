# Shaadi Book

Live prediction markets for Parsh and Spoorthi's wedding. Guests deposit USD, buy or sell LMSR-priced outcome shares, and resolve winnings after the event. Charity collection is handled outside the app.

## Quick Start

Prerequisites:

- Node.js 20 or newer
- npm 10 or newer
- Docker Desktop, or Docker Engine with Compose v2
- Optional for real auth/payments: Twilio Verify and Stripe test credentials

Fastest local setup:

```bash
npm run setup
```

The setup script prompts for your local admin phone number, house account details, Stripe/Twilio placeholders, and whether to install packages, start Docker services, and run Prisma migrations. It writes a local `.env` file and never commits secrets.

Manual setup:

```bash
cp env.example .env
npm install
docker compose up -d db redis
cd backend && npx prisma migrate deploy && cd ..
npm run dev:backend
npm run dev:frontend
```

Open:

- Frontend: http://localhost:3000
- Backend health: http://localhost:3001/health
- tRPC endpoint: http://localhost:3001/trpc

## What The Setup Script Does

Run:

```bash
npm run setup
```

Useful flags:

```bash
npm run setup -- --yes
npm run setup -- --no-install
npm run setup -- --no-docker
npm run setup -- --no-migrate
npm run setup -- --force
```

`--yes` accepts defaults for prompts that can safely default. `--force` allows overwriting an existing `.env`; otherwise the script creates a timestamped backup first.

The script configures:

- `JWT_SECRET` and `DB_PASSWORD` with generated secure values
- local Postgres and Redis URLs
- admin phone numbers for admin access
- house account phone and display name
- app URLs, CORS origin, and WebSocket URL
- Stripe, Twilio, SMS, and push-notification placeholders
- default market liquidity parameter

After setup, run the app in three terminals:

```bash
docker compose up -d db redis
npm run dev:backend
npm run dev:frontend
```

The backend and frontend dev scripts source the root `.env` before starting.

To run the backend in Docker instead of `npm run dev:backend`:

```bash
docker compose up -d --build api
```

## Environment

Copy `env.example` to `.env` or let `npm run setup` create it.

Required for local infrastructure:

- `DB_PASSWORD`
- `DATABASE_URL`
- `REDIS_URL`
- `JWT_SECRET`
- `ADMIN_PHONE_NUMBERS`
- `HOUSE_PHONE`
- `HOUSE_NAME`

Required for real OTP login:

- `TWILIO_ACCOUNT_SID`
- `TWILIO_AUTH_TOKEN`
- `TWILIO_VERIFY_SERVICE_SID`
- `TWILIO_PHONE_NUMBER`

Required for real deposits:

- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `STRIPE_PUBLISHABLE_KEY`

Optional:

- `TWILIO_TOLLFREE_NUMBER`
- `ENABLE_SMS_NOTIFICATIONS`
- `VAPID_PUBLIC_KEY`
- `VAPID_PRIVATE_KEY`
- `B_FLOOR_DEFAULT`
- `CORS_ORIGIN`
- `FRONTEND_URL`
- `NEXT_PUBLIC_API_URL`
- `NEXT_PUBLIC_WS_URL`

Phone numbers must be E.164 formatted, for example `+15551234567` or `+919876543210`.

## Development Commands

```bash
npm run dev:backend      # Express, tRPC, Socket.io on :3001
npm run dev:frontend     # Next.js on :3000
npm run build:backend
npm run build:frontend
npm run test:backend
npm run test:frontend
npm run typecheck
```

Database commands:

```bash
docker compose up -d db redis
cd backend && npx prisma migrate dev
cd backend && npx prisma migrate deploy
cd backend && npx prisma studio
```

Reset local data:

```bash
docker compose down -v
docker compose up -d db redis
cd backend && npx prisma migrate deploy
```

## Architecture Notes

- Frontend: Next.js 14 App Router, Tailwind CSS, shadcn-style components
- Backend: Node.js, Express, tRPC, Socket.io
- Database: PostgreSQL 16 with Prisma ORM
- Cache and realtime fanout: Redis
- Auth: phone OTP through Twilio Verify
- Payments: Stripe, USD
- Deployment: Docker Compose on DigitalOcean behind Caddy

Financial rules:

- User balances are derived from the append-only `transactions` ledger.
- No independent mutable user-balance column should be trusted.
- Purchases and sales run inside Postgres transactions.
- Ledger rows use double-entry accounts and a SHA-256 hash chain.
- `transactions` and `purchases` are append-only by trigger.
- Resolution is capped parimutuel: payout per winning share is `min($1.00, pool / winning_shares)`.
- Markets require at least 5 unique bettors before resolution.
- House seeding creates internal market-maker liquidity without Stripe.

## Production Deployment

Production runs on a DigitalOcean droplet with:

```bash
docker compose -f docker-compose.prod.yml up -d --build
docker compose -f docker-compose.prod.yml exec -T api npx prisma migrate deploy
```

The GitHub Action in `.github/workflows/deploy.yml` deploys automatically on push to `main`. The droplet keeps its own `.env`; do not commit production secrets.

Production URLs and services:

- Domain: https://markets.parshandspoorthi.com
- Caddy terminates TLS and proxies frontend, API, tRPC, health, and Socket.io.
- Postgres and Redis are internal Compose services.

## FAQs

### Do I need Stripe and Twilio to run locally?

No for basic development. You can start the app with placeholder Stripe and Twilio values, but real OTP login and real deposits require valid provider credentials.

### Why does the frontend run separately from Docker locally?

Local Compose starts Postgres, Redis, and optionally the API. Running Next.js with `npm run dev:frontend` keeps hot reload fast and avoids rebuilding the web image for every UI change.

### What phone number becomes an admin?

Any E.164 number in `ADMIN_PHONE_NUMBERS` becomes an admin after login, for example `+15551234567,+919876543210`.

### What is the House account?

The House account is the internal market-maker account used for seeding and AMM flows. Configure it with `HOUSE_PHONE` and `HOUSE_NAME`; it is not a Stripe customer.

### Where are balances stored?

Balances are not stored directly. They are derived from ledger rows in `transactions`.

### How do I inspect the database?

```bash
cd backend && npx prisma studio
```

### How do I clear bad local data?

```bash
docker compose down -v
docker compose up -d db redis
cd backend && npx prisma migrate deploy
```

### How do I test Stripe webhooks locally?

Use the Stripe CLI to forward webhooks to the backend:

```bash
stripe listen --forward-to localhost:3001/api/webhooks/stripe
```

Put the printed webhook signing secret in `STRIPE_WEBHOOK_SECRET`.

### Why is migration SQL ignored?

This repo's `.gitignore` currently ignores `backend/prisma/migrations/*.sql`. Coordinate before changing migration tracking behavior.

### What should I read before changing financial logic?

Read `PRD.md`, `AGENTS.md`, `backend/src/services/ledger.ts`, `backend/src/services/purchaseEngine.ts`, `backend/src/services/lmsr.ts`, and `backend/prisma/schema.prisma`.
