ARG NODE_CACHE_IMAGE
FROM ${NODE_CACHE_IMAGE} AS node-cache-updated

FROM alpine AS node-cache-export
COPY --from=node-cache-updated /tmp /tmp
