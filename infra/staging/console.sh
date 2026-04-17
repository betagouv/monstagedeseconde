#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
env_file="$project_root/.env"

if [[ -f "$env_file" ]]; then
  clever_app_staging_id="$(
    awk '
      /^[[:space:]]*(export[[:space:]]+)?CLEVER_APP_STAGING_ID[[:space:]]*=/ {
        v = $0
        sub(/^[[:space:]]*(export[[:space:]]+)?CLEVER_APP_STAGING_ID[[:space:]]*=[[:space:]]*/, "", v)
        gsub(/\r/, "", v)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
        if (v ~ /^".*"$/) { sub(/^"/, "", v); sub(/"$/, "", v) }
        if (v ~ /^\x27.*\x27$/) { sub(/^\x27/, "", v); sub(/\x27$/, "", v) }
        print v
      }
    ' "$env_file" | tail -n 1
  )"
  if [[ -n "$clever_app_staging_id" ]]; then
    export CLEVER_APP_STAGING_ID="$clever_app_staging_id"
  fi
fi

: "${CLEVER_APP_STAGING_ID:?Missing CLEVER_APP_STAGING_ID (export it or add CLEVER_APP_STAGING_ID=... to .env)}"
if [[ ! "$CLEVER_APP_STAGING_ID" =~ ^app_[0-9a-fA-F-]+$ ]]; then
  echo "Invalid CLEVER_APP_STAGING_ID: '$CLEVER_APP_STAGING_ID' (expected something like app_xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)" >&2
  exit 2
fi

SSH_PRIV="${SSH_PRIV:-$HOME/.ssh/clevercloud-monstage}"
if [ ! -f "$SSH_PRIV" ]; then
  echo "missing private key to push, check kdbx for content"
  exit 1;
fi;

echo "Connecting to Clever Cloud staging app: $CLEVER_APP_STAGING_ID" >&2
if command -v clever >/dev/null 2>&1; then
  exec clever ssh --app "$CLEVER_APP_STAGING_ID" -i "$SSH_PRIV"
fi

exec ssh -i "$SSH_PRIV" -o IdentitiesOnly=yes -t ssh@sshgateway-clevercloud-customers.services.clever-cloud.com "$CLEVER_APP_STAGING_ID"
