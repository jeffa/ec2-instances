#!/usr/bin/env bash
set -Eeuo pipefail

stack_dir="${LAMINAS_STACK_DIR:-$HOME/laminas-dev}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
log_file="${LAMINAS_DEPLOY_LOG:-$stack_dir/deploy.log}"
health_url="${APP_HEALTH_URL:-http://localhost/}"

mkdir -p "$stack_dir"
exec > >(tee -a "$log_file") 2>&1

source "$script_dir/00-compose.sh"
cd "$stack_dir"

diagnostics() {
  printf '%s\n' '--- deployment diagnostics ---'
  compose ps -a || true
  printf '%s\n' '--- app logs ---'
  compose logs --tail=100 app || true
  printf '%s\n' '--- database logs ---'
  compose logs --tail=100 db || true
}

on_error() {
  status=$?
  printf 'Deployment failed with status %s.\n' "$status"
  diagnostics
  exit "$status"
}
trap on_error ERR

wait_for_healthy() {
  service="$1"
  attempts="${2:-60}"

  for ((attempt = 1; attempt <= attempts; attempt++)); do
    container_id="$(compose ps -q "$service" 2>/dev/null || true)"
    if test -n "$container_id"; then
      status="$(docker inspect -f '{{.State.Status}}' "$container_id" 2>/dev/null || true)"
      health="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$container_id" 2>/dev/null || true)"
      if test "$status" = running && { test "$health" = healthy || test "$health" = none; }; then
        printf '%s is running (%s).\n' "$service" "$health"
        return 0
      fi
    fi
    printf 'Waiting for %s (%s/%s)...\n' "$service" "$attempt" "$attempts"
    sleep 2
  done

  printf 'Timed out waiting for %s.\n' "$service" >&2
  return 1
}

wait_for_http() {
  attempts="${1:-30}"

  for ((attempt = 1; attempt <= attempts; attempt++)); do
    if curl --fail --silent --show-error --head "$health_url"; then
      printf 'Application is responding at %s\n' "$health_url"
      return 0
    fi
    printf 'Waiting for HTTP readiness (%s/%s)...\n' "$attempt" "$attempts"
    sleep 2
  done

  printf 'Timed out waiting for HTTP readiness at %s.\n' "$health_url" >&2
  return 1
}

if test ! -f .env; then
  bash "$script_dir/02-create-env.sh"
  printf '%s\n' 'Edit ~/laminas-dev/.env, then run this script again.'
  exit 0
fi

bash "$script_dir/03-extract-app.sh"
bash "$script_dir/04-build-image.sh"
bash "$script_dir/05-start-database.sh"
wait_for_healthy db

set -a
. ./.env
set +a

session_table_count="$(compose exec -e MYSQL_PWD="$DB_ROOT_PASSWORD" -T db mariadb -uroot -N -B \
  -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${DB_NAME}' AND table_name='tblSessions';" \
  | tr -d '[:space:]')"

if test "${FORCE_DB_RESTORE:-0}" = "1" || test "$session_table_count" != "1"; then
  printf '%s\n' 'Database schema is absent or a forced restore was requested; importing the dump.'
  bash "$script_dir/06-restore-database.sh"
  touch "$stack_dir/.db-restored"
else
  printf '%s\n' 'Database schema is present; skipping SQL import.'
fi

bash "$script_dir/07-start-application.sh"
wait_for_healthy app
wait_for_http
bash "$script_dir/08-verify.sh"

printf '%s\n' 'Laminas deployment completed successfully.'
