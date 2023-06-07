FROM alpine AS node-cache-export

RUN --mount=type=cache,id=npm,sharing=locked,target=/data/node_modules,uid=1000 \
  mkdir -p /tmp/node_cache && cp -a /data/node_modules /tmp/node_cache
