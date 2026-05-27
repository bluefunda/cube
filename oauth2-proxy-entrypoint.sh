#!/bin/sh
# oauth2-proxy-entrypoint.sh — fetch SSO secrets from Vault before starting oauth2-proxy.
#
# Required env vars (shared from cube.env on the server):
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
  echo "[oauth2-proxy] Fetching SSO secrets from Vault at ${VAULT_ADDR} ..."

  TLS_FLAG=""
  if [ "$VAULT_SKIP_VERIFY" = "true" ] || [ "$VAULT_SKIP_VERIFY" = "1" ]; then
    TLS_FLAG="-k"
  fi

  VAULT_RESPONSE=$(curl -sf $TLS_FLAG \
    -H "X-Vault-Token: ${VAULT_TOKEN}" \
    "${VAULT_ADDR}/v1/${VAULT_MOUNT}/data/${VAULT_SECRET_PATH}" 2>/dev/null || true)

  if [ -z "$VAULT_RESPONSE" ]; then
    echo "[oauth2-proxy] WARNING: could not reach Vault — falling back to existing env vars." >&2
  else
    VALUE=$(echo "$VAULT_RESPONSE" | jq -r ".data.data.keycloak_client_secret // empty")
    if [ -n "$VALUE" ]; then
      export OAUTH2_PROXY_CLIENT_SECRET="$VALUE"
      echo "[oauth2-proxy] OAUTH2_PROXY_CLIENT_SECRET set from Vault."
    fi

    VALUE=$(echo "$VAULT_RESPONSE" | jq -r ".data.data.cookie_secret // empty")
    if [ -n "$VALUE" ]; then
      export OAUTH2_PROXY_COOKIE_SECRET="$VALUE"
      echo "[oauth2-proxy] OAUTH2_PROXY_COOKIE_SECRET set from Vault."
    fi
  fi
else
  echo "[oauth2-proxy] VAULT_ADDR or VAULT_TOKEN not set — skipping Vault." >&2
fi

exec /bin/oauth2-proxy "$@"
