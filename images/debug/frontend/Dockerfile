# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE
FROM ${SPRYKER_PARENT_IMAGE} AS frontend-debug

ARG SPRYKER_XDEBUG_MODE_ENABLE
ENV SPRYKER_XDEBUG_MODE_ENABLE=${SPRYKER_XDEBUG_MODE_ENABLE}

COPY --chown=root:root nginx/conf.d/debug.default.conf /etc/nginx/template/debug.default.conf
