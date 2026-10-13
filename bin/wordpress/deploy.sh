#!/usr/bin/env bash
set -Eeuo pipefail

: "${EC2_HOST:?Set EC2_HOST to the instance public DNS name or IP address}"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ec2_user="${EC2_USER:-ubuntu}"
remote_dir="${WORDPRESS_REMOTE_DIR:-wordpress-test}"
env_file="${WORDPRESS_ENV_FILE:-$repo_root/projects/wordpress/wordpress.env}"
remote_target="${ec2_user}@${EC2_HOST}"

if [[ ! -f "$env_file" ]]; then
  printf 'WordPress environment file not found: %s\n' "$env_file" >&2
  printf 'Copy projects/wordpress/wordpress.env.example to wordpress.env and set a password, or set WORDPRESS_ENV_FILE.\n' >&2
  exit 1
fi

if [[ "$remote_dir" == /* || "$remote_dir" == *..* || "$remote_dir" == *' '* ]]; then
  printf 'WORDPRESS_REMOTE_DIR must be a simple directory name under the remote home directory.\n' >&2
  exit 1
fi

printf 'Checking Docker on %s...\n' "$remote_target"
ssh "$remote_target" 'docker info >/dev/null 2>&1 || {
  printf "%s\n" "Docker is unavailable for this SSH user. Run the Ansible Docker playbook, reconnect, and try again." >&2
  exit 1
}'

printf 'Preparing remote WordPress directory...\n'
ssh "$remote_target" "mkdir -p \"\$HOME/$remote_dir/projects/wordpress\""

printf 'Copying WordPress deployment files...\n'
scp "$repo_root/projects/wordpress/install.sh" \
  "$remote_target:~/$remote_dir/projects/wordpress/install.sh"
scp "$env_file" \
  "$remote_target:~/$remote_dir/projects/wordpress/wordpress.env"

printf 'Launching WordPress on %s...\n' "$remote_target"
ssh "$remote_target" "chmod 700 \"\$HOME/$remote_dir/projects/wordpress/install.sh\" && chmod 600 \"\$HOME/$remote_dir/projects/wordpress/wordpress.env\" && cd \"\$HOME/$remote_dir\" && WORDPRESS_ENV_FILE=\"\$PWD/projects/wordpress/wordpress.env\" bash projects/wordpress/install.sh"

printf '%s\n' 'WordPress deployment completed.'
printf 'Open http://%s/ in a browser.\n' "$EC2_HOST"
