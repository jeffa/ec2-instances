#!/usr/bin/env bash
set -euo pipefail

stack_dir="${LAMINAS_STACK_DIR:-$HOME/laminas-dev}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/00-compose.sh"
cd "$stack_dir"
compose up -d app
compose exec app php bin/clear-config-cache.php
