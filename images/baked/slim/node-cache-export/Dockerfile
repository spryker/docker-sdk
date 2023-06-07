FROM alpine AS node-cache-export

RUN --mount=type=cache,id=npm-cache,sharing=locked,target=/home/spryker/.npm,uid=1000 --mount=type=cache,id=npm-modules,sharing=locked,target=/data/node_modules,uid=1000 \
    mkdir -p /tmp/node_modules && cp -a /data/node_modules /tmp/node_modules && \
    mkdir -p /tmp/npm_cache && cp -a /home/spryker/.npm /tmp/npm_cache
