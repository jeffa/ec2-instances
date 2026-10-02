#!/usr/bin/env bash
set -euo pipefail

stack_dir="${LAMINAS_STACK_DIR:-$HOME/laminas-dev}"
archive="${LAMINAS_STACK_ARCHIVE:-$HOME/laminas-dev-stack.tar.gz}"

test -f "$archive"
mkdir -p "$stack_dir"
tar -xzf "$archive" -C "$stack_dir" --strip-components=1
printf 'Stack configuration is ready in %s\n' "$stack_dir"
