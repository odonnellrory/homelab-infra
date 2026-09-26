#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"

# Deliberate deployment order.
# Caddy is started last so backend services are available first.
DEFAULT_STACKS=(
    pihole
    bitwarden
    actual
    glance
    uptime-kuma
    caddy
)

ACTION="${1:-deploy}"

if [[ $# -gt 0 ]]; then
    shift
fi

if [[ $# -gt 0 ]]; then
    STACKS=("$@")
else
    STACKS=("${DEFAULT_STACKS[@]}")
fi

log() {
    printf '\n==> %s\n' "$*"
}

die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

compose() {
    local stack="$1"
    shift

    local compose_file="${ROOT_DIR}/stacks/${stack}/docker-compose.yml"

    [[ -f "$compose_file" ]] ||
        die "Compose file not found for stack '${stack}': ${compose_file}"

    docker compose \
        --env-file "$ENV_FILE" \
        -f "$compose_file" \
        "$@"
}

check_requirements() {
    command -v docker >/dev/null 2>&1 ||
        die "Docker is not installed or is not in PATH."

    docker compose version >/dev/null 2>&1 ||
        die "Docker Compose plugin is not available."

    [[ -f "$ENV_FILE" ]] ||
        die "Missing ${ENV_FILE}. Copy .env.example to .env and configure it first."

    if ! docker info >/dev/null 2>&1; then
        die "Cannot communicate with the Docker daemon."
    fi
}

validate_stack() {
    local stack="$1"

    log "Validating ${stack}"
    compose "$stack" config >/dev/null
}

validate_all() {
    local stack

    for stack in "${STACKS[@]}"; do
        validate_stack "$stack"
    done

    log "All selected Compose configurations are valid."
}

deploy_stack() {
    local stack="$1"

    log "Pulling images for ${stack}"
    compose "$stack" pull

    log "Starting ${stack}"
    compose "$stack" up -d
}

deploy_all() {
    validate_all

    local stack

    for stack in "${STACKS[@]}"; do
        deploy_stack "$stack"
    done

    log "Deployment complete."
}

pull_all() {
    local stack

    for stack in "${STACKS[@]}"; do
        log "Pulling images for ${stack}"
        compose "$stack" pull
    done
}

restart_all() {
    validate_all

    local stack

    for stack in "${STACKS[@]}"; do
        log "Restarting ${stack}"
        compose "$stack" restart
    done
}

stop_all() {
    local stack

    # Stop in reverse order so Caddy goes down first.
    for ((i=${#STACKS[@]}-1; i>=0; i--)); do
        stack="${STACKS[$i]}"

        log "Stopping ${stack}"
        compose "$stack" down
    done
}

status_all() {
    local stack

    for stack in "${STACKS[@]}"; do
        log "Status: ${stack}"
        compose "$stack" ps
    done
}

usage() {
    cat <<'USAGE'
Usage:
  ./scripts/deploy.sh [command] [stack ...]

Commands:
  deploy      Validate, pull and start stacks (default)
  validate    Validate Compose configuration only
  pull        Pull container images only
  restart     Restart running stacks
  stop        Stop selected stacks
  status      Show selected stack status
  help        Show this help

Examples:
  ./scripts/deploy.sh
  ./scripts/deploy.sh validate
  ./scripts/deploy.sh deploy caddy
  ./scripts/deploy.sh restart pihole caddy
  ./scripts/deploy.sh status
USAGE
}

check_requirements

case "$ACTION" in
    deploy)
        deploy_all
        ;;
    validate)
        validate_all
        ;;
    pull)
        pull_all
        ;;
    restart)
        restart_all
        ;;
    stop)
        stop_all
        ;;
    status)
        status_all
        ;;
    help|-h|--help)
        usage
        ;;
    *)
        usage
        die "Unknown command: ${ACTION}"
        ;;
esac
