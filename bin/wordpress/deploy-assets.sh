#!/usr/bin/env bash
set -Eeuo pipefail

: "${EC2_HOST:?Set EC2_HOST to the instance public DNS name or IP address}"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ec2_user="${EC2_USER:-ubuntu}"
remote_dir="${WORDPRESS_REMOTE_DIR:-wordpress-test}"
archive="${1:?Usage: bin/wordpress/deploy-assets.sh ASSETS_ZIP [THEME_SLUG]}"
theme_slug="${2:-kabler-school-for-dogs}"
remote_target="${ec2_user}@${EC2_HOST}"

if [[ ! -f "$archive" ]]; then
  printf 'Asset archive not found: %s\n' "$archive" >&2
  exit 1
fi

if [[ ! "$theme_slug" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  printf 'Theme slug must contain only lowercase letters, numbers, and hyphens.\n' >&2
  exit 1
fi

if [[ "$remote_dir" == /* || "$remote_dir" == *..* || "$remote_dir" == *' '* ]]; then
  printf 'WORDPRESS_REMOTE_DIR must be a simple directory name under the remote home directory.\n' >&2
  exit 1
fi

remote_helper="~/$remote_dir/projects/wordpress/deploy-theme-assets.sh"
remote_archive="~/$remote_dir/assets/theme-assets.zip"

printf 'Preparing remote asset directory...\n'
ssh "$remote_target" "mkdir -p \"\$HOME/$remote_dir/projects/wordpress\" \"\$HOME/$remote_dir/assets\""

printf 'Copying asset deployment tool and payload...\n'
scp "$repo_root/projects/wordpress/deploy-theme-assets.sh" \
  "$remote_target:$remote_helper"
scp "$archive" "$remote_target:$remote_archive"

printf 'Deploying theme assets...\n'
ssh "$remote_target" "chmod 700 \"\$HOME/$remote_dir/projects/wordpress/deploy-theme-assets.sh\" && bash \"\$HOME/$remote_dir/projects/wordpress/deploy-theme-assets.sh\" \"\$HOME/$remote_dir/assets/theme-assets.zip\" '$theme_slug'"

printf '%s\n' 'Theme asset deployment completed.'
