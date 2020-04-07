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

USER spryker

COPY package.json package-lock.json ${srcRoot}/
COPY frontend ${srcRoot}/frontend
COPY tsconfig.json ${srcRoot}/
COPY config/Yves ${srcRoot}/config/Yves

ARG MODE='development'
ENV MODE=${MODE}

RUN --mount=type=cache,target=/home/spryker/.npm,from=npm_cache,source=/cache \
    vendor/bin/install -r docker -s build-static -s "build-static-${MODE}"

FROM nginx:1.17.9-alpine
RUN mkdir -p /data/public && chmod 0777 /data/public
COPY --from=builder /data/public /data/public
RUN find . -name "*.php" -type f -delete

ARG DEPLOYMENT_PATH

RUN mkdir -p /etc/nginx/template/ && chmod 0777 /etc/nginx/template/
COPY ${DEPLOYMENT_PATH}/context/nginx/frontend/default.conf.tmpl /etc/nginx/template/
COPY ${DEPLOYMENT_PATH}/context/nginx/frontend/entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["nginx", "-g", "daemon off;"]
VOLUME [ "/data/public" ]
