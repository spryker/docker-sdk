# syntax = docker/dockerfile:experimental

ARG FRONTEND_IMAGE_NAME
FROM ${FRONTEND_IMAGE_NAME} as frontend

ARG DEPLOYMENT_PATH
ENV DEPLOYMENT_PATH=${DEPLOYMENT_PATH}

USER root
RUN apk update && apk add bash

COPY --chown=root:root ${DEPLOYMENT_PATH}/bin/assets/tar-builder.sh /
RUN chmod +x /tar-builder.sh
