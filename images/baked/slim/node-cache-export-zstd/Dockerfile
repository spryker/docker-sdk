FROM alpine as tmp
COPY --from=node-cache-updated /node_cache.tar /tmp/node_cache.tar
RUN mkdir /tmp/temp & \
    cd /tmp/temp & \
    tar -xvf /tmp/node_cache.tar

FROM alpine AS node-cache-export
COPY --from=tmp /tmp/temp/tmp/ /tmp
RUN ls /tmp
