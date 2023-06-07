ARG NODE_CACHE_IMAGE

FROM ${NODE_CACHE_IMAGE} AS node-cache-import
RUN --mount=type=cache,id=npm,sharing=locked,target=/data/node_modules,uid=1000 \
    rm -rf /data/node_modules/* && \
    mv /tmp/node_cache/* /data/node_modules/

