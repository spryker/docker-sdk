# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE
FROM ${SPRYKER_PARENT_IMAGE} AS cli-debug

USER root
# Make self-signed certificate to be trusted locally
COPY nginx/ssl/ca.crt /usr/local/share/ca-certificates
RUN update-ca-certificates

USER spryker

RUN /usr/bin/install -d -m 777 /var/run/opcache/debug
COPY php/debug/etc/ /usr/local/etc/
