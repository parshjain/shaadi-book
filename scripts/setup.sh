#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"

ASSUME_YES=false
DO_INSTALL=true
DO_DOCKER=true
DO_MIGRATE=true
FORCE=false

for arg in "$@"; do
  case "$arg" in
    --yes|-y) ASSUME_YES=true ;;
    --no-install) DO_INSTALL=false ;;
    --no-docker) DO_DOCKER=false ;;
    --no-migrate) DO_MIGRATE=false ;;
    --force) FORCE=true ;;
    --help|-h)
      cat <<'HELP'
Usage: npm run setup -- [options]

Options:
  --yes, -y       Accept safe defaults where possible.
  --no-install   Skip npm install.
  --no-docker    Skip docker compose startup.
  --no-migrate   Skip Prisma migrations.
  --force        Overwrite .env without making a backup.
  --help, -h     Show this help.
HELP
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

random_hex() {
  local bytes="$1"
  if command_exists openssl; then
    openssl rand -hex "$bytes"
  else
    LC_ALL=C tr -dc 'a-f0-9' </dev/urandom | head -c "$((bytes * 2))"
    echo
  fi
}

env_value() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/}"
  printf '"%s"' "$value"
}

prompt() {
  local label="$1"
  local default_value="${2:-}"
  local value

  if [[ "$ASSUME_YES" == true && -n "$default_value" ]]; then
    printf '%s\n' "$default_value"
    return
  fi

  if [[ -n "$default_value" ]]; then
    read -r -p "$label [$default_value]: " value
    printf '%s\n' "${value:-$default_value}"
  else
    read -r -p "$label: " value
    printf '%s\n' "$value"
  fi
}

prompt_secret() {
  local label="$1"
  local default_value="${2:-}"
  local value

  if [[ "$ASSUME_YES" == true && -n "$default_value" ]]; then
    printf '%s\n' "$default_value"
    return
  fi

  if [[ -n "$default_value" ]]; then
    read -r -s -p "$label [press enter to keep default]: " value
    echo >&2
    printf '%s\n' "${value:-$default_value}"
  else
    read -r -s -p "$label: " value
    echo >&2
    printf '%s\n' "$value"
  fi
}

yes_no() {
  local label="$1"
  local default_value="$2"
  local value

  if [[ "$ASSUME_YES" == true ]]; then
    [[ "$default_value" == "y" ]]
    return
  fi

  read -r -p "$label [$default_value]: " value
  value="${value:-$default_value}"
  [[ "$value" =~ ^[Yy]$ ]]
}

validate_phone_list() {
  local phones="$1"
  if [[ -z "$phones" ]]; then
    return 1
  fi
  [[ "$phones" =~ ^\+[0-9]{8,15}(,\+[0-9]{8,15})*$ ]]
}

validate_phone() {
  local phone="$1"
  [[ "$phone" =~ ^\+[0-9]{8,15}$ ]]
}

main() {
  cd "$ROOT_DIR"

  if ! command_exists node; then
    echo "Node.js 20+ is required. Install Node, then rerun this script." >&2
    exit 1
  fi

  if ! command_exists npm; then
    echo "npm 10+ is required. Install npm, then rerun this script." >&2
    exit 1
  fi

  if [[ "$DO_DOCKER" == true ]] && ! command_exists docker; then
    echo "Docker is required unless you pass --no-docker." >&2
    exit 1
  fi

  echo "Shaadi Book setup"
  echo

  local default_admin="+15551234567"
  local admin_phones
  admin_phones="$(prompt "Admin phone numbers, comma-separated E.164" "$default_admin")"
  until validate_phone_list "$admin_phones"; do
    echo "Use E.164 format, for example +15551234567 or +15551234567,+919876543210." >&2
    admin_phones="$(prompt "Admin phone numbers, comma-separated E.164" "$default_admin")"
  done

  local house_phone
  house_phone="$(prompt "House account phone, E.164" "+15550000000")"
  until validate_phone "$house_phone"; do
    echo "Use one E.164 phone number, for example +15550000000." >&2
    house_phone="$(prompt "House account phone, E.164" "+15550000000")"
  done

  local house_name
  house_name="$(prompt "House display name" "House")"

  local local_domain
  local_domain="$(prompt "Frontend URL" "http://localhost:3000")"

  local api_url
  api_url="$(prompt "Backend API URL" "http://localhost:3001")"

  local db_password
  db_password="$(prompt_secret "Postgres password" "$(random_hex 18)")"

  local jwt_secret
  jwt_secret="$(prompt_secret "JWT secret" "$(random_hex 32)")"

  local stripe_secret
  stripe_secret="$(prompt "Stripe secret key" "sk_test_replace_me")"

  local stripe_publishable
  stripe_publishable="$(prompt "Stripe publishable key" "pk_test_replace_me")"

  local stripe_webhook
  stripe_webhook="$(prompt "Stripe webhook secret" "whsec_replace_me")"

  local twilio_sid
  twilio_sid="$(prompt "Twilio Account SID" "AC_replace_me")"

  local twilio_token
  twilio_token="$(prompt_secret "Twilio Auth Token" "replace_me")"

  local twilio_verify
  twilio_verify="$(prompt "Twilio Verify Service SID" "VA_replace_me")"

  local twilio_phone
  twilio_phone="$(prompt "Twilio sender phone, E.164" "+15550000001")"

  local b_floor
  b_floor="$(prompt "Default b floor for new markets" "20")"

  if [[ -f "$ENV_FILE" ]]; then
    if [[ "$FORCE" == true ]]; then
      echo "Overwriting existing .env"
    else
      local backup="$ENV_FILE.backup.$(date +%Y%m%d%H%M%S)"
      cp "$ENV_FILE" "$backup"
      echo "Backed up existing .env to $backup"
    fi
  fi

  cat >"$ENV_FILE" <<ENV
# Generated by scripts/setup.sh on $(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Auth
JWT_SECRET=$(env_value "$jwt_secret")
TWILIO_ACCOUNT_SID=$(env_value "$twilio_sid")
TWILIO_AUTH_TOKEN=$(env_value "$twilio_token")
TWILIO_VERIFY_SERVICE_SID=$(env_value "$twilio_verify")
TWILIO_PHONE_NUMBER=$(env_value "$twilio_phone")
TWILIO_TOLLFREE_NUMBER=

# Payments
STRIPE_SECRET_KEY=$(env_value "$stripe_secret")
STRIPE_WEBHOOK_SECRET=$(env_value "$stripe_webhook")
STRIPE_PUBLISHABLE_KEY=$(env_value "$stripe_publishable")
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=$(env_value "$stripe_publishable")

# Database
DB_PASSWORD=$(env_value "$db_password")
DATABASE_URL=$(env_value "postgres://shaadi:$db_password@localhost:5432/shaadi_book")

# Redis
REDIS_URL="redis://localhost:6379"

# App Config
ADMIN_PHONE_NUMBERS=$(env_value "$admin_phones")
HOUSE_PHONE=$(env_value "$house_phone")
HOUSE_NAME=$(env_value "$house_name")
B_FLOOR_DEFAULT=$(env_value "$b_floor")
NODE_ENV="development"
PORT="3001"
CORS_ORIGIN=$(env_value "$local_domain")
FRONTEND_URL=$(env_value "$local_domain")
ENABLE_SMS_NOTIFICATIONS="false"
VAPID_PUBLIC_KEY=
VAPID_PRIVATE_KEY=

# Frontend public values
NEXT_PUBLIC_WS_URL=$(env_value "$api_url")
NEXT_PUBLIC_API_URL=$(env_value "$api_url")
ENV

  echo "Wrote .env"

  if [[ "$DO_INSTALL" == true ]]; then
    npm install
  fi

  if [[ "$DO_DOCKER" == true ]]; then
    docker compose up -d db redis
  fi

  if [[ "$DO_MIGRATE" == true ]]; then
    if [[ "$DO_DOCKER" == false ]]; then
      echo "Skipping migrations because Docker startup was skipped. Run cd backend && npx prisma migrate deploy when Postgres is available."
    else
      (cd backend && npx prisma migrate deploy)
    fi
  fi

  if yes_no "Start the Dockerized API now" "n"; then
    docker compose up -d --build api
  fi

  echo
  echo "Setup complete."
  echo "Run the backend:  npm run dev:backend"
  echo "Run the frontend: npm run dev:frontend"
  echo "Open:           $local_domain"
}

main "$@"
