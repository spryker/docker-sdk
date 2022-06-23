# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE
FROM ${SPRYKER_PARENT_IMAGE} AS cli-debug

USER root
RUN /usr/bin/install -d -m 777 /var/run/opcache/debug
USER spryker
COPY php/debug/etc/ /usr/local/etc/
