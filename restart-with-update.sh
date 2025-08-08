#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

say() { echo -e "${GREEN}$1${NC}"; }
warn() { echo -e "${YELLOW}$1${NC}"; }
err() { echo -e "${RED}$1${NC}"; }

say "Updating repository..."
cd "$ROOT_DIR"
if ! command -v git >/dev/null 2>&1; then
  err "git not found. Please install git."
  exit 1
fi

git fetch --all --prune
if ! git pull --rebase --autostash; then
  err "Git pull failed. Resolve conflicts and re-run."
  exit 1
fi

say "Updating backend dependencies..."
cd "$ROOT_DIR/backend"
if [ -f package-lock.json ]; then
  npm ci
else
  npm install
fi

say "Regenerating Prisma client..."
npm run db:generate

if command -v pm2 >/dev/null 2>&1; then
  if pm2 describe attendkal-backend >/dev/null 2>&1; then
    say "Reloading backend with PM2..."
    pm2 reload attendkal-backend --update-env
  else
    say "Starting backend with PM2..."
    pm2 start ecosystem.config.cjs --env development
  fi
  pm2 save || true
else
  warn "PM2 not found. Install with: npm i -g pm2"
  warn "Start backend manually: cd backend && npm run dev"
fi

say "Updating Flutter packages..."
cd "$ROOT_DIR"
if command -v flutter >/dev/null 2>&1; then
  flutter pub get
else
  warn "Flutter not found. Skipping Flutter steps."
fi

say "Done."
warn "If Flutter is running, use its hot-reload (r) or restart (R)." 