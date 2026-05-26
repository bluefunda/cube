#!/bin/sh
# docker-entrypoint.sh — fetch PostgreSQL credentials from Vault before starting Cube.
#
# Required env vars (in cube.env on the server):
#   VAULT_ADDR        e.g. https://vault.internal:8200
#   VAULT_TOKEN       token with read access to the secret path
#
# Optional:
#   VAULT_SKIP_VERIFY set to "true" to skip TLS verification (self-signed certs)
#   VAULT_MOUNT       KV v2 mount path (default: secret)
#   VAULT_SECRET_PATH path within the mount (default: apps/abaper/services/cube)

set -e

VAULT_MOUNT="${VAULT_MOUNT:-secret}"
VAULT_SECRET_PATH="${VAULT_SECRET_PATH:-apps/abaper/services/cube}"

if [ -n "$VAULT_ADDR" ] && [ -n "$VAULT_TOKEN" ]; then
  echo "[entrypoint] Fetching DB credentials from Vault at ${VAULT_ADDR} ..."

  TLS_FLAG=""
  if [ "$VAULT_SKIP_VERIFY" = "true" ] || [ "$VAULT_SKIP_VERIFY" = "1" ]; then
    TLS_FLAG="-k"
  fi

  VAULT_RESPONSE=$(curl -sf $TLS_FLAG \
    -H "X-Vault-Token: ${VAULT_TOKEN}" \
    "${VAULT_ADDR}/v1/${VAULT_MOUNT}/data/${VAULT_SECRET_PATH}" 2>/dev/null || true)

  if [ -z "$VAULT_RESPONSE" ]; then
    echo "[entrypoint] WARNING: could not reach Vault — falling back to existing env vars." >&2
  else
    vault_export() {
      ENV_KEY="$1"
      VAULT_FIELD="$2"
      VALUE=$(echo "$VAULT_RESPONSE" | jq -r ".data.data.${VAULT_FIELD} // empty")
      if [ -n "$VALUE" ]; then
        export "$ENV_KEY"="$VALUE"
        echo "[entrypoint] $ENV_KEY set from Vault."
      fi
    }

    # PostgreSQL credentials
    vault_export CUBEJS_DB_TYPE db_type
    vault_export CUBEJS_DB_HOST db_host
    vault_export CUBEJS_DB_PORT db_port
    vault_export CUBEJS_DB_NAME db_name
    vault_export CUBEJS_DB_USER db_user
    vault_export CUBEJS_DB_PASS db_pass
    vault_export CUBEJS_DB_SSL  db_ssl

    # Cube API secret
    vault_export CUBEJS_API_SECRET api_secret
  fi
else
  echo "[entrypoint] VAULT_ADDR or VAULT_TOKEN not set — skipping Vault." >&2
fi

exec /usr/local/bin/docker-entrypoint.sh "$@"
