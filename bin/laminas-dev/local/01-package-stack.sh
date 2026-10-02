#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
archive="${LAMINAS_STACK_ARCHIVE:-/tmp/laminas-dev-stack.tar.gz}"
staging_dir="$(mktemp -d)"
trap 'rm -rf "$staging_dir"' EXIT

cp -R "$repo_root/laminas-dev" "$staging_dir/laminas-dev"
mkdir -p "$staging_dir/laminas-dev/remote"
cp "$repo_root"/bin/laminas-dev/remote/*.sh "$staging_dir/laminas-dev/remote/"

tar \
  --exclude='laminas-dev/app' \
  --exclude='laminas-dev/.env' \
  -czf "$archive" \
  -C "$staging_dir" \
  laminas-dev

printf 'Created %s\n' "$archive"
