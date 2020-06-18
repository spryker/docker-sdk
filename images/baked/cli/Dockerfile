# syntax = docker/dockerfile:experimental
ARG SPRYKER_APPLICATION_IMAGE

FROM ${SPRYKER_APPLICATION_IMAGE}

# Blackfire client
RUN mkdir -p /tmp/blackfire \
    && curl -A "Docker" -L https://blackfire.io/api/v1/releases/client/linux_static/amd64 | tar zxp -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire /usr/bin/blackfire \
    && rm -Rf /tmp/blackfire

ENV PATH=/data/vendor/bin:$PATH

RUN --mount=type=cache,id=aptlib,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,id=aptcache,sharing=locked,target=/var/cache/apt \
  bash -c 'if [ ! -z "$(which apt)" ]; then apt-get update && apt-get install -y \
     nodejs \
     npm \
     inotify-tools \
     netcat-openbsd \
     git \
     ; fi'
# Debian contains outdated NPM package
RUN --mount=type=cache,id=npm,sharing=locked,target=/root/.npm \
  bash -c 'if [ ! -z "$(which apt)" ]; then npm install npm@latest -g; fi'

RUN --mount=type=cache,id=apk,sharing=locked,target=/var/cache/apk ln -vs /var/cache/apk /etc/apk/cache && \
  bash -c 'if [ ! -z "$(which apk)" ]; then apk update && apk add \
     nodejs \
     npm \
     inotify-tools \
     netcat-openbsd \
     coreutils \
     ncurses \
     git \
     ; fi'

WORKDIR /data

USER spryker

# Install composer modules for Spryker
COPY --chown=spryker:spryker composer.json composer.lock ${srcRoot}/
ARG COMPOSER_AUTH
ARG SPRYKER_COMPOSER_MODE
RUN --mount=type=cache,id=composer,sharing=locked,target=/home/spryker/.composer/cache,uid=1000 \
    COMPOSER_AUTH="${COMPOSER_AUTH}" composer install --no-interaction ${SPRYKER_COMPOSER_MODE}

ARG SPRYKER_COMPOSER_AUTOLOAD
RUN --mount=type=cache,id=composer,sharing=locked,target=/home/spryker/.composer/cache,uid=1000 \
  composer dump-autoload ${SPRYKER_COMPOSER_AUTOLOAD}

USER root

# Tests contain transfer declaration
COPY --chown=spryker:spryker tests ${srcRoot}/tests

ENV DEVELOPMENT_CONSOLE_COMMANDS=1
RUN vendor/bin/install -r docker -s build-development

ARG DEPLOYMENT_PATH
ENV DEPLOYMENT_PATH=${DEPLOYMENT_PATH}

COPY ${DEPLOYMENT_PATH}/context/nginx/ssl/ca.crt /usr/local/share/ca-certificates
RUN update-ca-certificates

USER spryker

RUN mkdir -p /home/spryker/env
COPY --chown=spryker:spryker ${DEPLOYMENT_PATH}/context/cli /home/spryker/bin
RUN find /home/spryker/bin -type f -exec chmod +x {} \;
ENV PATH=/home/spryker/bin:$PATH

RUN mkdir -p /home/spryker/history && touch /home/spryker/history/.bash_history && chmod 0600 /home/spryker/history/.bash_history
ENV HISTFILE=/home/spryker/history/.bash_history

ENV NEWRELIC_ENABLED=0
