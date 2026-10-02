#!/usr/bin/env bash
set -euo pipefail

stack_dir="${LAMINAS_STACK_DIR:-$HOME/laminas-dev}"
dump="${LAMINAS_DB_PAYLOAD:-$HOME/horsesns_safari-dev.sql.gz}"

test -f "$dump"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/00-compose.sh"
cd "$stack_dir"
set -a
. ./.env
set +a

gzip -dc "$dump" | \
  compose exec -e MYSQL_PWD="$DB_ROOT_PASSWORD" -T db mariadb -uroot
