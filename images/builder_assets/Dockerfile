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
RUN mkdir -p /assets/Zed \
    && mkdir -p /assets/Yves \
    && mkdir -p /assets/Driver \
    && mkdir -p public/Zed \
    && mkdir -p public/Yves \
    && rm -rf public/Zed/assets \
    && rm -rf public/Yves/assets \
    && ln -s /assets/Zed public/Zed/assets \
    && ln -s /assets/Yves public/Yves/assets \
    && ln -s /assets/Driver public/Driver/assets

ARG MODE='development'
ENV MODE=${MODE}

RUN --mount=type=cache,target=/home/spryker/.npm,from=npm_cache,source=/cache \
    BUILD_COMMAND=$([ "${MODE}" == "production" ] && echo -n ':production' || true) \
    && vendor/bin/console frontend:project:install-dependencies -v \
    && vendor/bin/console frontend:yves:install-dependencies -v \
    && npm run "yves${BUILD_COMMAND}" \
    && vendor/bin/console frontend:zed:install-dependencies -v \
    && npm run "zed${BUILD_COMMAND}" \
    && sed -i 's/\/assets\/\//\/assets\//g' public/Zed/assets/css/spryker-zed-gui-commons.css

FROM alpine
RUN mkdir -p /assets && chmod 0777 /assets
COPY --from=builder /assets /assets

VOLUME [ "/assets" ]
