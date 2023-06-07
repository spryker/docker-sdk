ARG NODE_CACHE_IMAGE

FROM ${NODE_CACHE_IMAGE} AS node-cache-import
RUN --mount=type=cache,id=npm-cache,sharing=locked,target=/home/spryker/.npm,uid=1000 --mount=type=cache,id=npm-modules,sharing=locked,target=/data/node_modules,uid=1000 \
    rm -rf /data/node_modules/* && mv /tmp/node_modules/node_modules/* /data/node_modules/ && \
    rm -rf /home/spryker/.npm/* && mv /tmp/npm_cache/.npm/* /home/spryker/.npm/

