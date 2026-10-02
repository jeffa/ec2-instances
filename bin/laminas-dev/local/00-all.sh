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
#!/usr/bin/env bash
set -euo pipefail

: "${EC2_HOST:?Set EC2_HOST to the instance public DNS name or IP address}"
ec2_user="${EC2_USER:-ec2-user}"
archive="${LAMINAS_STACK_ARCHIVE:-/tmp/laminas-dev-stack.tar.gz}"

test -f "$archive"
scp "$archive" "${ec2_user}@${EC2_HOST}:~/"
#!/usr/bin/env bash
set -euo pipefail

: "${EC2_HOST:?Set EC2_HOST to the instance public DNS name or IP address}"
ec2_user="${EC2_USER:-ec2-user}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
payload_dir="${LAMINAS_PAYLOAD_DIR:-$repo_root/laminas-input}"

test -f "$payload_dir/laminas-app.tar.gz"
test -f "$payload_dir/horsesns_safari-dev.sql.gz"

scp \
  "$payload_dir/laminas-app.tar.gz" \
  "$payload_dir/horsesns_safari-dev.sql.gz" \
  "${ec2_user}@${EC2_HOST}:~/"
