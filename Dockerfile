# Extend official Cube image — only override BlueFunda branding assets
FROM cubejs/cube:latest

# Replace Cube logo with BlueFunda logo in the pre-built playground
COPY packages/cubejs-playground/public/bluefunda-logo.svg \
     /cube/node_modules/@cubejs-backend/server-core/playground/cube-core-logo-adapted_for_dark_bg.svg
