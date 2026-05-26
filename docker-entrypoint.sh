#!/bin/sh
# docker-entrypoint.sh — fetch Cube config and DB credentials from Vault before starting Cube.
#
# Required env vars (injected by your orchestrator / Kubernetes secret):
#   VAULT_ADDR        e.g. https://vault.internal:8200
#   VAULT_TOKEN       a periodic or short-lived token with read access
#
# Optional:
#   VAULT_SKIP_VERIFY set to "true" to skip TLS verification (self-signed certs)
#   VAULT_MOUNT       KV v2 mount path (default: secret)
#   VAULT_SECRET_PATH path within the mount (default: apps/abaper/services/cube)

set -e

VAULT_MOUNT="${VAULT_MOUNT:-secret}"
VAULT_SECRET_PATH="${VAULT_SECRET_PATH:-apps/abaper/services/cube}"

if [ -n "$VAULT_ADDR" ] && [ -n "$VAULT_TOKEN" ]; then
  echo "[entrypoint] Fetching Cube config from Vault at ${VAULT_ADDR} ..."

  # Build curl TLS flag
  TLS_FLAG=""
  if [ "$VAULT_SKIP_VERIFY" = "true" ] || [ "$VAULT_SKIP_VERIFY" = "1" ]; then
    TLS_FLAG="-k"
  fi

  # Vault KV v2 API: GET /v1/{mount}/data/{path}
  VAULT_RESPONSE=$(curl -sf $TLS_FLAG \
    -H "X-Vault-Token: ${VAULT_TOKEN}" \
    "${VAULT_ADDR}/v1/${VAULT_MOUNT}/data/${VAULT_SECRET_PATH}")

  if [ -z "$VAULT_RESPONSE" ]; then
    echo "[entrypoint] ERROR: empty response from Vault. Check VAULT_ADDR, VAULT_TOKEN, and path." >&2
    exit 1
  fi

  # Helper: extract a field from Vault response, only export if non-empty
  vault_export() {
    ENV_KEY="$1"
    VAULT_FIELD="$2"
    VALUE=$(echo "$VAULT_RESPONSE" | jq -r ".data.data.${VAULT_FIELD} // empty")
    if [ -n "$VALUE" ]; then
      export "$ENV_KEY"="$VALUE"
      echo "[entrypoint] $ENV_KEY set from Vault."
    fi
  }

  # --- Database ---
  vault_export CUBEJS_DB_TYPE     db_type
  vault_export CUBEJS_DB_HOST     db_host
  vault_export CUBEJS_DB_PORT     db_port
  vault_export CUBEJS_DB_NAME     db_name
  vault_export CUBEJS_DB_USER     db_user
  vault_export CUBEJS_DB_PASS     db_pass
  vault_export CUBEJS_DB_SSL      db_ssl

  # --- Cube API ---
  vault_export CUBEJS_API_SECRET  api_secret

  # --- Cube Store (optional) ---
  vault_export CUBEJS_CUBESTORE_HOST  cubestore_host
  vault_export CUBEJS_CUBESTORE_PORT  cubestore_port

  # --- Redis (optional) ---
  vault_export CUBEJS_REDIS_URL   redis_url

else
  echo "[entrypoint] VAULT_ADDR or VAULT_TOKEN not set — skipping Vault, using existing env vars." >&2
fi

# Hand off to the official Cube entrypoint (which then runs: cubejs server)
exec docker-entrypoint.sh "$@"
