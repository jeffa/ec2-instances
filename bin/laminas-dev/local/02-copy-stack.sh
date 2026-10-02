#!/usr/bin/env bash
set -euo pipefail

: "${EC2_HOST:?Set EC2_HOST to the instance public DNS name or IP address}"
ec2_user="${EC2_USER:-ec2-user}"
archive="${LAMINAS_STACK_ARCHIVE:-/tmp/laminas-dev-stack.tar.gz}"

test -f "$archive"
scp "$archive" "${ec2_user}@${EC2_HOST}:~/"
