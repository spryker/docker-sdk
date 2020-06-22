# syntax = docker/dockerfile:experimental
ARG SPRYKER_PLATFORM_IMAGE

FROM ${SPRYKER_PLATFORM_IMAGE} AS spryker_app_dependencies

USER spryker

# Install composer modules for Spryker
COPY --chown=spryker:spryker composer.json composer.lock ${srcRoot}/
ARG COMPOSER_AUTH
ARG SPRYKER_COMPOSER_MODE
RUN --mount=type=cache,id=composer,sharing=locked,target=/home/spryker/.composer/cache,uid=1000 \
    COMPOSER_AUTH="${COMPOSER_AUTH}" composer install --no-interaction ${SPRYKER_COMPOSER_MODE}

### Intermediate container - with dependencies, PHP code and configs
FROM spryker_app_dependencies AS spryker_app_base
COPY --chown=spryker:spryker src ${srcRoot}/src
COPY --chown=spryker:spryker config ${srcRoot}/config
COPY --chown=spryker:spryker *.php ${srcRoot}/
# translations in /data are needed for build below
COPY --chown=spryker:spryker data ${srcRoot}/data
RUN chmod 600 ${srcRoot}/config/Zed/*.key

RUN --mount=type=cache,id=composer,sharing=locked,target=/home/spryker/.composer/cache,uid=1000 \
  composer dump-autoload -o

ARG SPRYKER_PIPELINE
ENV SPRYKER_PIPELINE=${SPRYKER_PIPELINE}
ARG APPLICATION_ENV
ARG SPRYKER_DB_ENGINE
ENV APPLICATION_ENV=${APPLICATION_ENV}
ENV SPRYKER_DB_ENGINE=${SPRYKER_DB_ENGINE}

COPY --chown=spryker:spryker data ${srcRoot}/data
RUN vendor/bin/install -r ${SPRYKER_PIPELINE} -s build -s build-production -vvv

ARG SPRYKER_COMPOSER_AUTOLOAD
RUN --mount=type=cache,id=composer,sharing=locked,target=/home/spryker/.composer/cache,uid=1000 \
  composer dump-autoload ${SPRYKER_COMPOSER_AUTOLOAD}

### Final container with public directory and data
FROM spryker_app_base AS spryker_app

# Add remaining Spryker files/directories
COPY --chown=spryker:spryker public ${srcRoot}/public
COPY --chown=spryker:spryker frontend ${srcRoot}/frontend
COPY --chown=spryker:spryker .* *.* LICENSE ${srcRoot}/

# Run FPM as default command
USER root
RUN rm -rf /var/run/opcache/*
RUN chown -R spryker:spryker /home/spryker

ARG SPRYKER_BUILD_HASH='current'
ENV SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH}
ARG SPRYKER_BUILD_STAMP=''
ENV SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP}

CMD [ "php-fpm", "--nodaemonize" ]
EXPOSE 9000
