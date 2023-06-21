# syntax = docker/dockerfile:1.5
FROM node-cache-updated AS node-cache-updated2

FROM alpine AS node-cache-export
COPY --from=node-cache-updated2 /tmp /tmp
