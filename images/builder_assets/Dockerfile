# syntax = docker/dockerfile:experimental
ARG SPRYKER_DOCKER_TAG
ARG SPRYKER_DOCKER_PREFIX

FROM alpine:3.9 AS npm_cache
RUN mkdir -p /cache && chmod 0777 /cache

FROM ${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG}

RUN apk update && apk add \
  nodejs \
  npm \
  git

USER spryker

COPY package.json package-lock.json ${srcRoot}/

COPY frontend ${srcRoot}/frontend
COPY tsconfig.json ${srcRoot}/
RUN mkdir -p /data/public/assets/Zed \
    && mkdir -p /data/public/assets/Yves \
    && mkdir -p public/Zed \
    && mkdir -p public/Yves \
    && ln -s /data/public/assets/Zed public/Zed/assets \
    && ln -s /data/public/assets/Yves public/Yves/assets

RUN --mount=type=cache,target=/home/spryker/.npm,from=npm_cache,source=/cache \
    vendor/bin/install -r docker -s build-static

VOLUME [ "/data/public/assets" ]
