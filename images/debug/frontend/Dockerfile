# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE
FROM ${SPRYKER_PARENT_IMAGE}

COPY --chown=root:root nginx/conf.d/debug.default.conf /etc/nginx/conf.d/debug.default.conf
