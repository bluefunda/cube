# Extend official Cube image — only override BlueFunda branding assets
FROM cubejs/cube:latest

# Replace Cube logo with BlueFunda logo in the pre-built playground
COPY packages/cubejs-playground/public/bluefunda-logo.svg \
     /cube/node_modules/@cubejs-backend/server-core/playground/cube-core-logo-adapted_for_dark_bg.svg

# Replace favicons with BlueFunda favicon
COPY packages/cubejs-playground/public/favicon.ico \
     /cube/node_modules/@cubejs-backend/server-core/playground/favicon.ico
COPY packages/cubejs-playground/public/favicon-16x16.png \
     /cube/node_modules/@cubejs-backend/server-core/playground/favicon-16x16.png
COPY packages/cubejs-playground/public/favicon-32x32.png \
     /cube/node_modules/@cubejs-backend/server-core/playground/favicon-32x32.png

# Install jq for Vault JSON parsing in the entrypoint script
RUN apt-get update -qq && apt-get install -y --no-install-recommends jq curl \
    && rm -rf /var/lib/apt/lists/*

# Vault entrypoint: fetches DB credentials from Vault before starting Cube
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Wrap the official Cube entrypoint — CMD ["cubejs", "server"] is inherited from base
ENTRYPOINT ["/docker-entrypoint.sh"]
