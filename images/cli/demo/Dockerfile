# syntax = docker/dockerfile:experimental
ARG SPRYKER_DOCKER_TAG
ARG SPRYKER_DOCKER_PREFIX

### Intermediate container - base for composer cache
FROM alpine:3.9 AS composer_cache
RUN mkdir -p /cache && chmod 0777 /cache

FROM ${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG}

ARG SPRYKER_LOG_DIRECTORY=/var/log/spryker

ENV PATH=/data/vendor/bin:$PATH

RUN bash -c '[ ! -z "$(which apt)" ] && apt-get update && apt-get install -y \
     nodejs \
     npm \
     netcat-openbsd \
     git \
     redis-tools \
     || true'
# Debian contains outdated NPM package
RUN bash -c '[ ! -z "$(which apt)" ] && npm install npm@latest -g || true'

RUN bash -c '[ ! -z "$(which apk)" ] && apk update && apk add \
     nodejs \
     npm \
     netcat-openbsd \
     coreutils \
     git \
     redis \
     || true'

RUN mkdir -p ${SPRYKER_LOG_DIRECTORY}
RUN chown spryker:spryker ${SPRYKER_LOG_DIRECTORY}
WORKDIR /data

ARG DEPLOYMENT_PATH
ENV DEPLOYMENT_PATH=${DEPLOYMENT_PATH}

USER spryker
# Install composer modules for Spryker
COPY --chown=spryker:spryker composer.json composer.lock ${srcRoot}/
ARG GITHUB_TOKEN
RUN bash -c 'if [ ! -z $GITHUB_TOKEN ]; then export COMPOSER_AUTH="{\"github-oauth\": {\"github.com\": \"${GITHUB_TOKEN}\"}}"; fi; \
    composer install --no-interaction --optimize-autoloader --dev'
RUN composer dump-autoload -o

USER root

# Tests contain transfer declaration
COPY --chown=spryker:spryker tests ${srcRoot}/tests

ENV DEVELOPMENT_CONSOLE_COMMANDS=1
RUN vendor/bin/install -r docker -s build-development

COPY ${DEPLOYMENT_PATH}/context/cli/execute.sh /usr/local/bin/execute.sh
RUN chmod +x /usr/local/bin/execute.sh

USER spryker
