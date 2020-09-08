# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE
FROM ${SPRYKER_PARENT_IMAGE} AS frontend-debug

COPY --chown=root:root nginx/conf.d/debug.default.conf /etc/nginx/conf.d/debug.default.conf
