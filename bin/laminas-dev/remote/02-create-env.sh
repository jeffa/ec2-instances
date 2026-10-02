#!/usr/bin/env bash
set -euo pipefail

stack_dir="${LAMINAS_STACK_DIR:-$HOME/laminas-dev}"
cd "$stack_dir"

if test ! -f .env; then
  cp .env.example .env
  chmod 600 .env
  printf 'Created %s/.env. Edit DB_PASSWORD and DB_ROOT_PASSWORD before continuing.\n' "$stack_dir"
else
  printf '%s/.env already exists; leaving it unchanged.\n' "$stack_dir"
fi
