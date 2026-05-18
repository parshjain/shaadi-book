#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKIP_MIGRATE=false

for arg in "$@"; do
  case "$arg" in
    --skip-migrate) SKIP_MIGRATE=true ;;
    --help|-h)
      cat <<'HELP'
Usage: npm run dev:local -- [options]

Starts the local database, Redis, backend, and frontend.

Options:
  --skip-migrate  Do not run Prisma migrations before startup.
  --help, -h      Show this help.
HELP
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

cd "$ROOT_DIR"

if [[ ! -f .env ]]; then
  echo "No .env found. Starting setup first."
  bash scripts/setup.sh --no-docker --no-migrate
fi

echo "Starting Postgres and Redis..."
docker compose up -d db redis

if [[ "$SKIP_MIGRATE" == false ]]; then
  echo "Applying database migrations..."
  (cd backend && npx prisma migrate deploy)
fi

cleanup() {
  if [[ -n "${BACKEND_PID:-}" ]]; then
    kill "$BACKEND_PID" 2>/dev/null || true
  fi
  if [[ -n "${FRONTEND_PID:-}" ]]; then
    kill "$FRONTEND_PID" 2>/dev/null || true
  fi
}

trap cleanup EXIT INT TERM

echo "Starting backend on http://localhost:3001"
npm run dev:backend &
BACKEND_PID=$!

echo "Starting frontend on http://localhost:3000"
npm run dev:frontend &
FRONTEND_PID=$!

echo
echo "Shaadi Book is starting."
echo "Open http://localhost:3000"
echo "Press Ctrl+C to stop the app."
echo

wait -n "$BACKEND_PID" "$FRONTEND_PID"
