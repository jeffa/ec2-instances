#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
env_file="${WORDPRESS_ENV_FILE:-$script_dir/projects/wordpress/wordpress.env}"

if [[ -f "$env_file" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$env_file"
  set +a
fi

: "${WORDPRESS_DB_PASSWORD:?Set WORDPRESS_DB_PASSWORD in $env_file or the environment before running this script}"

db_name="${WORDPRESS_DB_NAME:-wordpress}"
db_user="${WORDPRESS_DB_USER:-wordpress}"
network_name="${WORDPRESS_NETWORK:-wordpress-network}"
db_volume="${WORDPRESS_DB_VOLUME:-wordpress-db}"
files_volume="${WORDPRESS_FILES_VOLUME:-wordpress-files}"
db_image="${WORDPRESS_DB_IMAGE:-mysql:8.0}"
app_image="${WORDPRESS_IMAGE:-wordpress:apache}"

docker network create "$network_name" 2>/dev/null || true
docker volume create "$db_volume" >/dev/null
docker volume create "$files_volume" >/dev/null

docker run -d \
  --name wp-db \
  --network "$network_name" \
  --restart unless-stopped \
  -e MYSQL_DATABASE="$db_name" \
  -e MYSQL_USER="$db_user" \
  -e MYSQL_PASSWORD="$WORDPRESS_DB_PASSWORD" \
  -e MYSQL_RANDOM_ROOT_PASSWORD=1 \
  -v "$db_volume:/var/lib/mysql" \
  "$db_image"

sleep 2

docker run -d \
  --name wordpress \
  --network "$network_name" \
  --restart unless-stopped \
  -p 80:80 \
  -e WORDPRESS_DB_HOST=wp-db:3306 \
  -e WORDPRESS_DB_USER="$db_user" \
  -e WORDPRESS_DB_PASSWORD="$WORDPRESS_DB_PASSWORD" \
  -e WORDPRESS_DB_NAME="$db_name" \
  -v "$files_volume:/var/www/html" \
  "$app_image"
