FROM alpine as tmp
COPY --from=node-cache-updated /node_cache.tar /tmp/node_cache.tar
RUN tar -xvf /tmp/node_cache.tar
RUN ls /
RUN ls /tmp
RUN ls /node_cache

FROM alpine AS node-cache-export
COPY --from=tmp /node_cache /tmp
RUN ls /
RUN ls /tmp
RUN ls /node_cache
