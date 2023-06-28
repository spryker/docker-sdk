FROM node-distributive AS npm-precacher
LABEL "spryker.image" "none"

COPY --chown=spryker:spryker package.json* package-lock.json* /root/

RUN --mount=type=cache,id=npm-cache,sharing=locked,target=/root/.npm \
    --mount=type=cache,id=npm-modules,sharing=locked,target=/root/node_modules \
    cd /root \
    && sh -c 'if [ -f ${srcRoot}/package.json ]; then npm install --prefer-offline || npm ci --prefer-offline || true; fi'
