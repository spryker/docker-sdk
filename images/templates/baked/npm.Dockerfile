FROM node-distributive AS npm-precacher
LABEL "spryker.image" "none"

WORKDIR /root

COPY --chown=spryker:spryker package.jso[n] package-lock.jso[n] /root/

RUN --mount=type=cache,id=npm,sharing=locked,target=/root/.npm \
    --mount=type=cache,id=npm-modules,sharing=locked,target=/root/node_modules \
    <<EOT
      if [ -f ./package.json ]; then
        npm ci || npm install || true
      fi
EOT
