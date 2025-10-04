#!/usr/bin/env bash
set -euo pipefail

# Wrapper script to start the compose stack with Docker or Podman.
# It prefers Podman if PODMAN env var is set or podman-compose is available.
# Usage: ./scripts/compose-up.sh [up|down|build|restart] [additional docker-compose args]

CMD=${1:-up}
shift || true

# decide whether to use podman-compose or docker-compose
use_podman=false
if [ "${PODMAN:-}" = "1" ]; then
  use_podman=true
else
  if command -v podman-compose >/dev/null 2>&1; then
    use_podman=true
  fi
fi

if [ "$use_podman" = true ]; then
  echo "Using podman-compose"
  COMPOSE_CMD=podman-compose
else
  echo "Using docker-compose"
  COMPOSE_CMD=docker-compose
fi

case "$CMD" in
  up)
    "$COMPOSE_CMD" up -d --build "$@"
    ;;
  down)
    "$COMPOSE_CMD" down "$@"
    ;;
  build)
    "$COMPOSE_CMD" build "$@"
    ;;
  restart)
    "$COMPOSE_CMD" down && "$COMPOSE_CMD" up -d --build "$@"
    ;;
  *)
    echo "Unknown command: $CMD"
    echo "Usage: $0 [up|down|build|restart]"
    exit 2
    ;;
esac
