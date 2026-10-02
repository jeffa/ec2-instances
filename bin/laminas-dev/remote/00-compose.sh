#!/usr/bin/env bash

compose() {
  if docker compose version >/dev/null 2>&1; then
    docker compose "$@"
  elif command -v docker-compose >/dev/null 2>&1; then
    docker-compose "$@"
  else
    printf '%s\n' 'Docker Compose is not installed. Install the Docker Compose plugin or docker-compose.' >&2
    return 1
  fi
}
