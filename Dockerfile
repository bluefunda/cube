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

# Replace browser tab title "Cube Playground" → "BlueFunda Analytics"
RUN sed -i 's/<title>Cube Playground<\/title>/<title>BlueFunda Analytics<\/title>/g' \
    /cube/node_modules/@cubejs-backend/server-core/playground/index.html

# Inject SSO logout button next to the Slack icon in the Cube header
RUN sed -i 's|</body>|<script>(function(){function inject(){var slack=document.querySelector("a[href*=\"slack\"]");if(!slack)return false;if(document.getElementById("sso-logout-btn"))return true;var btn=document.createElement("a");btn.id="sso-logout-btn";btn.href="/oauth2/sign_out";btn.title="Sign Out";btn.style="display:inline-flex;align-items:center;margin-left:8px;cursor:pointer;opacity:0.75;transition:opacity 0.2s";btn.onmouseover=function(){this.style.opacity="1"};btn.onmouseout=function(){this.style.opacity="0.75"};btn.innerHTML='\''<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"18\" height=\"18\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4\"/><polyline points=\"16 17 21 12 16 7\"/><line x1=\"21\" y1=\"12\" x2=\"9\" y2=\"12\"/></svg>'\'';slack.parentNode.insertBefore(btn,slack.nextSibling);return true}if(!inject()){var o=new MutationObserver(function(){if(inject())o.disconnect()});o.observe(document.body,{childList:true,subtree:true})}})()</script></body>|' \
    /cube/node_modules/@cubejs-backend/server-core/playground/index.html

# Install jq and curl for Vault JSON parsing in the entrypoint script
RUN apt-get update -qq && apt-get install -y --no-install-recommends jq curl \
    && rm -rf /var/lib/apt/lists/*

# Vault entrypoint: fetches PostgreSQL credentials from Vault before starting Cube
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# CMD must be re-declared — Docker resets it to null when ENTRYPOINT is overridden
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["cubejs", "server"]
