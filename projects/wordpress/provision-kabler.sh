#!/usr/bin/env bash

# One-command Kabler test-site provisioning.
# Run from the directory containing this file and provision-kabler.php:
#   bash provision-kabler.sh

set -euo pipefail

CONTAINER_NAME="${1:-wordpress}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROVISION_FILE="$SCRIPT_DIR/provision-kabler.php"
LOCAL_WP_CLI="${TMPDIR:-/tmp}/kabler-wp-cli.phar"

if ! docker inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
	printf 'Docker container not found: %s\n' "$CONTAINER_NAME" >&2
	exit 1
fi

if [ ! -f "$PROVISION_FILE" ]; then
	printf 'Missing provisioning file: %s\n' "$PROVISION_FILE" >&2
	exit 1
fi

if [ ! -f "$LOCAL_WP_CLI" ]; then
	curl -fsSLo "$LOCAL_WP_CLI" \
		https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
fi

printf '%s\n' 'Copying provisioning files...'
docker cp "$PROVISION_FILE" "$CONTAINER_NAME:/tmp/provision-kabler.php"
docker cp "$LOCAL_WP_CLI" "$CONTAINER_NAME:/tmp/wp-cli.phar"

printf '%s\n' 'Creating pages and navigation...'
docker exec "$CONTAINER_NAME" \
	php /tmp/wp-cli.phar \
	--allow-root \
	--path=/var/www/html \
	eval-file /tmp/provision-kabler.php

PERMALINKS="$(docker exec "$CONTAINER_NAME" \
	php /tmp/wp-cli.phar \
	--allow-root \
	--path=/var/www/html \
	option get permalink_structure | tr -d '\r')"

if [ "$PERMALINKS" != '/%postname%/' ]; then
	printf '%s\n' 'Applying clean permalink structure...'
	docker exec "$CONTAINER_NAME" \
		php /tmp/wp-cli.phar \
		--allow-root \
		--path=/var/www/html \
		rewrite structure '/%postname%/' --hard
fi

docker exec "$CONTAINER_NAME" rm -f /tmp/provision-kabler.php /tmp/wp-cli.phar
printf '%s\n' 'Kabler test site provisioning complete.'
