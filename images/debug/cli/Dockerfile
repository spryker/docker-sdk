# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE
FROM ${SPRYKER_PARENT_IMAGE} AS cli-debug

USER root
# Temporarily switch to HTTP for Alpine repositories to bootstrap ca-certificates
RUN sed -i 's/https:\/\/dl-cdn.alpinelinux.org/http:\/\/dl-cdn.alpinelinux.org/g' /etc/apk/repositories \
    && apk add --no-cache ca-certificates \
    && sed -i 's/http:\/\/dl-cdn.alpinelinux.org/https:\/\/dl-cdn.alpinelinux.org/g' /etc/apk/repositories

WORKDIR /data
COPY certs-system.crt "/usr/local/share/ca-certificates/host-certs.crt"
RUN update-ca-certificates
USER spryker
#TEST
ENV NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/host-certs.crt
RUN npm config set cafile /usr/local/share/ca-certificates/host-certs.crt


COPY php/debug/etc/ /usr/local/etc/
