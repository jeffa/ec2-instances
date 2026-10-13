#!/usr/bin/env bash
set -Eeuo pipefail

archive="${1:?Usage: deploy-theme-assets.sh ASSETS_ZIP [THEME_SLUG]}"
theme_slug="${2:-kabler-school-for-dogs}"
container="${WORDPRESS_CONTAINER:-wordpress}"

if [[ ! -f "$archive" ]]; then
  printf 'Asset archive not found: %s\n' "$archive" >&2
  exit 1
fi

if [[ ! "$theme_slug" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  printf 'Theme slug must contain only lowercase letters, numbers, and hyphens.\n' >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  printf '%s\n' 'python3 is required to extract the asset archive.' >&2
  exit 1
fi

if ! docker inspect "$container" >/dev/null 2>&1; then
  printf 'WordPress container not found: %s\n' "$container" >&2
  exit 1
fi

if [[ "$(docker inspect -f '{{.State.Running}}' "$container")" != true ]]; then
  printf 'WordPress container is not running: %s\n' "$container" >&2
  exit 1
fi

extract_dir="$(mktemp -d "/tmp/${theme_slug}-assets.XXXXXX")"
trap 'rm -rf "$extract_dir"' EXIT

python3 -m zipfile -e "$archive" "$extract_dir"

source_dir="$extract_dir/$theme_slug/assets"
target_dir="/var/www/html/wp-content/themes/$theme_slug/assets"

if [[ ! -d "$source_dir" ]]; then
  printf 'Expected assets directory was not found in the archive: %s/assets\n' "$theme_slug" >&2
  exit 1
fi

docker exec "$container" sh -c "mkdir -p '$target_dir'"
docker cp "$source_dir/." "$container:$target_dir/"
docker exec "$container" sh -c "chown -R www-data:www-data '$target_dir'"

printf 'Deployed theme assets to %s:%s\n' "$container" "$target_dir"
