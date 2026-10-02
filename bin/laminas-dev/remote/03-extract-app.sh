#!/usr/bin/env bash
set -euo pipefail

stack_dir="${LAMINAS_STACK_DIR:-$HOME/laminas-dev}"
payload="${LAMINAS_APP_PAYLOAD:-$HOME/laminas-app.tar.gz}"

test -f "$payload"
mkdir -p "$stack_dir/app"
tar -xzf "$payload" -C "$stack_dir/app"
test -f "$stack_dir/app/composer.json"
printf 'Application source is ready in %s/app\n' "$stack_dir"
