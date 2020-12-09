# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE

FROM ${SPRYKER_PARENT_IMAGE} AS application-production-dependencies

USER spryker

# Install composer modules for Spryker
COPY --chown=spryker:spryker composer.json composer.lock ${srcRoot}/
ARG SPRYKER_COMPOSER_MODE
RUN --mount=type=cache,id=composer,sharing=locked,target=/home/spryker/.composer/cache,uid=1000 \
  --mount=type=ssh,uid=1000 --mount=type=secret,id=secrets-env,uid=1000 \
  set -o allexport && . /run/secrets/secrets-env && set +o allexport \
  && composer install --no-scripts --no-interaction ${SPRYKER_COMPOSER_MODE} -vvv

FROM application-production-dependencies AS application-production-codebase

COPY --chown=spryker:spryker src ${srcRoot}/src
COPY --chown=spryker:spryker config ${srcRoot}/config
COPY --chown=spryker:spryker *.php ${srcRoot}/
# TODO: Move codebase related stuff from data folder to src. In ideal: translations in /data are needed for build below
COPY --chown=spryker:spryker data ${srcRoot}/data
RUN chmod 600 ${srcRoot}/config/Zed/*.key 2>/dev/null || true

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

FROM application-production-codebase AS application-production

COPY --chown=spryker:spryker public ${srcRoot}/public
COPY --chown=spryker:spryker frontend ${srcRoot}/frontend
COPY --chown=spryker:spryker .yarn* ${srcRoot}/.yarn
COPY --chown=spryker:spryker .* *.* LICENSE ${srcRoot}/

USER root
RUN rm -rf /var/run/opcache/*
RUN chown -R spryker:spryker /home/spryker

ARG SPRYKER_BUILD_HASH='current'
ENV SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH}
ARG SPRYKER_BUILD_STAMP=''
ENV SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP}

CMD [ "php-fpm", "--nodaemonize" ]
EXPOSE 9000
