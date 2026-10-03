#!/usr/bin/env bash
set -euo pipefail

stack_dir="${LAMINAS_STACK_DIR:-$HOME/laminas-dev}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$stack_dir"

if test ! -f .env; then
  bash "$script_dir/02-create-env.sh"
  printf '%s\n' 'Edit ~/laminas-dev/.env, then run this script again.'
  exit 0
fi

bash "$script_dir/03-extract-app.sh"
bash "$script_dir/04-build-image.sh"
bash "$script_dir/05-start-database.sh"

restore_marker="$stack_dir/.db-restored"
if test -f "$restore_marker" && test "${FORCE_DB_RESTORE:-0}" != "1"; then
  printf '%s\n' 'Database restore already completed; skipping SQL import.'
else
  bash "$script_dir/06-restore-database.sh"
  touch "$restore_marker"
fi

bash "$script_dir/07-start-application.sh"
bash "$script_dir/08-verify.sh"
