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
