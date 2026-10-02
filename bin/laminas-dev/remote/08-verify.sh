#!/usr/bin/env bash
set -euo pipefail

stack_dir="${LAMINAS_STACK_DIR:-$HOME/laminas-dev}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/00-compose.sh"
cd "$stack_dir"
compose ps
curl -I http://localhost/
compose exec app composer check-platform-reqs --no-dev
