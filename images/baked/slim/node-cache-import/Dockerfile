ARG NODE_CACHE_IMAGE

FROM ${NODE_CACHE_IMAGE} AS node-cache-import
RUN --mount=type=cache,id=npm-cache,sharing=locked,target=/home/spryker/.npm,uid=1000 --mount=type=cache,id=npm-modules,sharing=locked,target=/data/node_modules,uid=1000 \
    apk add --no-cache rsync && \
    rsync -av --delete /tmp/node_modules/node_modules/* /data/node_modules/ && \
    rsync -av --delete /tmp/npm_cache/.npm/* /home/spryker/.npm/

