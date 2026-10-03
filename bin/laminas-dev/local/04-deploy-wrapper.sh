#!/usr/bin/env bash
set -euo pipefail

: "${EC2_HOST:?Set EC2_HOST to the instance public DNS name or IP address}"
ec2_user="${EC2_USER:-ec2-user}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
remote_target="${ec2_user}@${EC2_HOST}"

"$script_dir/01-package-stack.sh"
"$script_dir/02-copy-stack.sh"
"$script_dir/03-copy-payloads.sh"

ssh "$remote_target" \
  'mkdir -p "$HOME/laminas-dev" && tar -xzf "$HOME/laminas-dev-stack.tar.gz" -C "$HOME/laminas-dev" --strip-components=1'

printf '%s\n' 'Stack and payloads transferred; edit .env on EC2, then run remote/99-deploy.sh.'
