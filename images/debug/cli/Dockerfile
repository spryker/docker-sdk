# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE
FROM ${SPRYKER_PARENT_IMAGE} AS cli-debug

RUN /usr/bin/install -d -m 777 /var/run/opcache/debug
COPY php/debug/etc/ /usr/local/etc/
