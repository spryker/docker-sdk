# syntax = docker/dockerfile:experimental
ARG SPRYKER_PLATFORM_IMAGE=spryker/php:7.2

### Intermediate container - base for composer cache
FROM alpine:3.9 AS composer_cache
RUN mkdir -p /cache && chmod 0777 /cache

# Intermediate container - base for app, with composer deps
FROM ${SPRYKER_PLATFORM_IMAGE} AS spryker_app_dependencies

# Create log directory
ARG SPRYKER_LOG_DIRECTORY
ENV SPRYKER_LOG_DIRECTORY=${SPRYKER_LOG_DIRECTORY}
RUN mkdir -p ${SPRYKER_LOG_DIRECTORY} && \
    chown spryker:spryker ${SPRYKER_LOG_DIRECTORY}

# Creates the list of known hosts
ARG KNOWN_HOSTS
RUN mkdir -p /home/spryker/.ssh && chmod 0700 /home/spryker/.ssh
RUN bash -c '[ ! -z "${KNOWN_HOSTS}" ] && ssh-keyscan -t rsa ${KNOWN_HOSTS} >> /home/spryker/.ssh/known_hosts || true'
RUN chown spryker:spryker -R /home/spryker/.ssh

WORKDIR /data
USER spryker
ENV SPRYKER_IN_DOCKER=1

# Install composer modules for Spryker
COPY --chown=spryker:spryker composer.json composer.lock ${srcRoot}/
ARG GITHUB_TOKEN
ARG SPRYKER_COMPOSER_MODE
RUN --mount=type=cache,target=/home/spryker/.composer/cache,from=composer_cache,source=/cache \
  bash -c 'if [ ! -z $GITHUB_TOKEN ]; then export COMPOSER_AUTH="{\"github-oauth\": {\"github.com\": \"${GITHUB_TOKEN}\"}}"; fi; \
    composer install --no-interaction ${SPRYKER_COMPOSER_MODE}'

### Intermediate container - with dependencies, PHP code and configs
FROM spryker_app_dependencies AS spryker_app_base
COPY --chown=spryker:spryker src ${srcRoot}/src
COPY --chown=spryker:spryker config ${srcRoot}/config
COPY --chown=spryker:spryker *.php ${srcRoot}/
RUN chmod 600 ${srcRoot}/config/Zed/*.key

RUN --mount=type=cache,target=/home/spryker/.composer/cache,from=composer_cache,source=/cache \
  composer dump-autoload -o

ARG APPLICATION_ENV
ARG SPRYKER_DB_ENGINE
ENV APPLICATION_ENV=${APPLICATION_ENV}
ENV SPRYKER_DB_ENGINE=${SPRYKER_DB_ENGINE}

RUN vendor/bin/install -r docker -s build -s build-production -vvv

### Final container, with testing tools, public directory and data
FROM spryker_app_base AS spryker_app

# Add remaining Spryker files/directories
COPY --chown=spryker:spryker data ${srcRoot}/data
COPY --chown=spryker:spryker public ${srcRoot}/public
COPY --chown=spryker:spryker frontend ${srcRoot}/frontend
COPY --chown=spryker:spryker .* *.* LICENSE ${srcRoot}/

ARG SPRYKER_COMPOSER_AUTOLOAD
RUN --mount=type=cache,target=/home/spryker/.composer/cache,from=composer_cache,source=/cache \
  composer dump-autoload ${SPRYKER_COMPOSER_AUTOLOAD}

ARG DEPLOYMENT_PATH
ENV DEPLOYMENT_PATH=${DEPLOYMENT_PATH}

# PHP configuration
COPY ${DEPLOYMENT_PATH}/context/php/php-fpm.d/worker.conf /usr/local/etc/php-fpm.d/worker.conf
COPY ${DEPLOYMENT_PATH}/context/php/php.ini /usr/local/etc/php/
# TODO use opcache before composer somehow
COPY ${DEPLOYMENT_PATH}/context/php/conf.d/opcache.ini /usr/local/etc/php/conf.d/

ARG SPRYKER_BUILD_HASH='stage'
ENV SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH}
ARG SPRYKER_BUILD_STAMP=''
ENV SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP}

# Run FPM as default command
USER root

ARG BLACKFIRE_ENABLED
RUN bash -c '[ "${BLACKFIRE_ENABLED}" == "1" ] && mv /usr/local/etc/php/disabled/blackfire.ini /usr/local/etc/php/conf.d/blackfire.ini || true'
ARG NEWRELIC_ENABLED
RUN bash -c '[ "${NEWRELIC_ENABLED}" == "1" ] && mv /usr/local/etc/php/disabled/newrelic.ini /usr/local/etc/php/conf.d/newrelic.ini || true'

RUN rm -rf /var/run/opcache/*
RUN chown -R spryker:spryker /home/spryker

CMD [ "php-fpm", "--nodaemonize" ]
EXPOSE 9000
