# syntax = docker/dockerfile:experimental
ARG SPRYKER_DOCKER_TAG
ARG SPRYKER_DOCKER_PREFIX

FROM alpine AS npm_cache
RUN mkdir -p /cache && chmod 0777 /cache

FROM ${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG} AS builder

RUN bash -c '[ ! -z "$(which apt)" ] && apt-get update && apt-get install -y \
     nodejs \
     npm \
     git \
     && apt-get clean \
     || true'
# Debian contains outdated NPM package
RUN bash -c '[ ! -z "$(which apt)" ] && npm install npm@latest -g || true'

RUN bash -c '[ ! -z "$(which apk)" ] && apk update && apk add --no-cache \
     nodejs \
     npm \
     git \
     || true'

RUN mkdir -p /assets && chmod 0777 /assets

USER spryker

COPY package.json package-lock.json ${srcRoot}/
COPY frontend ${srcRoot}/frontend
COPY tsconfig.json ${srcRoot}/
COPY config/Yves ${srcRoot}/config/Yves

ARG MODE='development'
ENV MODE=${MODE}

RUN --mount=type=cache,target=/home/spryker/.npm,from=npm_cache,source=/cache \
    vendor/bin/install -r docker -s build-static -s "build-static-${MODE}"

FROM alpine
RUN mkdir -p /assets && chmod 0777 /assets
COPY --from=builder /data/public /assets
RUN find . -name "*.php" -type f -delete

VOLUME [ "/assets" ]
