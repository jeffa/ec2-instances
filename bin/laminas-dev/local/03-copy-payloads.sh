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
