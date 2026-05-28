#!/usr/bin/env bash
set -e

dc_base="$(docker compose version &>/dev/null && echo 'docker compose' || echo 'docker-compose')"
dc=($dc_base)

# Export host UID/GID
export PUID=$(id -u)
export PGID=$(id -g)

if [[ -f "../.env" ]]; then
    "${dc[@]}" --env-file .env --env-file ../.env "$@" up -d
else
    "${dc[@]}" "$@" up -d
fi
