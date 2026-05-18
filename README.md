# Shaadi Book

A live prediction-market app for wedding guests. People join with a phone number, deposit USD, buy or sell outcome shares, and settle winnings after the event. The app handles the market, wallet, ledger, admin flow, and realtime experience; charity collection happens outside the app.

## Pick Your Path

### I just want to run it

Use this if you are non-technical or you want the fastest local demo.

```bash
npm run setup
npm run dev:local
```

Then open http://localhost:3000.

What happens:

- `npm run setup` asks a few plain-English questions and creates `.env` for you.
- `npm run dev:local` starts Postgres, Redis, the backend, and the frontend.
- The first admin is the phone number you enter during setup.

### I am a developer

Use this if you want separate terminals and direct control.

```bash
npm install
docker compose up -d db redis
cd backend && npx prisma migrate deploy && cd ..
npm run dev:backend
npm run dev:frontend
```

Useful developer commands:

```bash
npm run setup:check
npm run test:backend
npm run test:frontend
npm run typecheck
```

### I am deploying it

Production runs with Docker Compose behind Caddy:

```bash
docker compose -f docker-compose.prod.yml up -d --build
docker compose -f docker-compose.prod.yml exec -T api npx prisma migrate deploy
```

Pushes to `main` trigger the GitHub Actions deploy workflow for the DigitalOcean droplet.

## Requirements

For local use:

- Docker Desktop running
- Node.js 20 or newer
- npm 10 or newer

For real OTP and payments:

- Twilio Verify credentials
- Stripe test or live credentials

You can run the app without real Twilio and Stripe credentials for basic development, but real phone login and deposits need provider keys.

## Setup Wizard

Run:

```bash
npm run setup
```

The wizard asks for:

- Your admin phone number
- The House account name and phone number
- Local app URLs
- Stripe keys, or placeholders for local-only work
- Twilio keys, or placeholders for local-only work
- Whether to install dependencies, start services, and run migrations

The script writes `.env` and backs up an existing `.env` before replacing it.

Useful options:

```bash
npm run setup -- --yes          # Accept safe defaults
npm run setup -- --check        # Check whether your machine is ready
npm run setup -- --no-install   # Do not run npm install
npm run setup -- --no-docker    # Do not start Docker services
npm run setup -- --no-migrate   # Do not run Prisma migrations
npm run setup -- --force        # Replace .env without creating a backup
```

## One-Command Local Run

After setup:

```bash
npm run dev:local
```

This starts:

- Postgres on `localhost:5432`
- Redis on `localhost:6379`
- API, tRPC, and Socket.io on `localhost:3001`
- Next.js frontend on `localhost:3000`

Press `Ctrl+C` to stop the backend and frontend. Postgres and Redis stay running in Docker so your data remains available.

To stop the database and Redis:

```bash
docker compose down
```

To delete all local data and start fresh:

```bash
docker compose down -v
npm run dev:local
```

## Customization Checklist

Edit `.env` when you want to customize the app.

| Setting | What it controls |
| --- | --- |
| `ADMIN_PHONE_NUMBERS` | Comma-separated admin phones, like `+15551234567,+919876543210` |
| `HOUSE_NAME` | Display name for the internal market-maker account |
| `HOUSE_PHONE` | Phone number used for the House account |
| `FRONTEND_URL` | Browser URL for the app |
| `CORS_ORIGIN` | Origin the backend accepts browser requests from |
| `NEXT_PUBLIC_API_URL` | Public backend URL used by the frontend |
| `NEXT_PUBLIC_WS_URL` | Public WebSocket URL used by the frontend |
| `B_FLOOR_DEFAULT` | Default liquidity floor for new markets |
| `ENABLE_SMS_NOTIFICATIONS` | Turns periodic SMS notifications on or off |

Phone numbers must use E.164 format, such as `+15551234567` or `+919876543210`.

## Environment Variables

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

## Common Tasks

### Open the app

```bash
npm run dev:local
```

Then open http://localhost:3000.

### Check whether the backend is alive

```bash
curl http://localhost:3001/health
```

### Open the database browser

```bash
cd backend && npx prisma studio
```

### Run migrations

```bash
cd backend && npx prisma migrate deploy
```

### Test Stripe webhooks locally

```bash
stripe listen --forward-to localhost:3001/api/webhooks/stripe
```

Put the printed webhook signing secret in `STRIPE_WEBHOOK_SECRET`.

### Run only infrastructure

```bash
docker compose up -d db redis
```

### Run the API in Docker

```bash
docker compose up -d --build api
```

## Project Structure

```text
shaadi-book/
|-- frontend/          # Next.js app
|-- backend/           # Express, tRPC, Socket.io, Prisma
|-- shared/            # Shared package workspace
|-- scripts/           # Setup and local development helpers
|-- docker-compose.yml
|-- docker-compose.prod.yml
|-- env.example
`-- PRD.md
```

## Architecture

- Frontend: Next.js 14 App Router and Tailwind CSS
- Backend: Node.js, Express, tRPC, Socket.io
- Database: PostgreSQL 16 with Prisma ORM
- Realtime: Redis-backed Socket.io
- Auth: Twilio Verify phone OTP
- Payments: Stripe in USD
- Hosting: DigitalOcean droplet with Docker Compose and Caddy

Financial guarantees:

- User balances are derived from the append-only `transactions` ledger.
- No independent mutable user-balance column should be trusted.
- Purchases and sales run inside Postgres transactions.
- Ledger rows use double-entry accounts and a SHA-256 hash chain.
- `transactions` and `purchases` are append-only by trigger.
- Resolution is capped parimutuel: payout per winning share is `min($1.00, pool / winning_shares)`.
- Markets require at least 5 unique bettors before resolution.
- House seeding creates internal market-maker liquidity without Stripe.

## Production Notes

The production droplet keeps its own `.env`; never commit production secrets.

Deployment flow:

```bash
git push origin main
```

The deploy workflow runs:

```bash
cd /opt/shaadi-book
git pull origin main
docker compose -f docker-compose.prod.yml build
docker compose -f docker-compose.prod.yml up -d
docker compose -f docker-compose.prod.yml exec -T api npx prisma migrate deploy
```

Production endpoints:

- App: https://markets.parshandspoorthi.com
- Health: https://markets.parshandspoorthi.com/health

## FAQs

### I am not technical. What do I type?

Type these two commands from the project folder:

```bash
npm run setup
npm run dev:local
```

When the app says it is starting, open http://localhost:3000.

### What should I enter for the admin phone?

Enter the phone number you want to use for admin access, including country code. Examples: `+15551234567` for the US or `+919876543210` for India.

### Can I leave Stripe and Twilio as placeholders?

Yes for basic local development. You need real keys only for real OTP login, SMS, Stripe checkout, and webhook testing.

### Why does Docker need to be running?

Docker runs the local Postgres database and Redis service. The app needs both.

### How do I know my setup is ready?

```bash
npm run setup:check
```

### Where is my local configuration?

In `.env`. This file is intentionally ignored by Git.

### Where are balances stored?

Balances are derived from ledger rows in `transactions`. Do not add or trust a separate mutable balance field.

### What should I read before changing money movement?

Read `PRD.md`, `AGENTS.md`, `backend/src/services/ledger.ts`, `backend/src/services/purchaseEngine.ts`, `backend/src/services/lmsr.ts`, and `backend/prisma/schema.prisma`.
