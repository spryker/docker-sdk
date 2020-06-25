# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE
ARG SPRYKER_APPLICATION_IMAGE

FROM ${SPRYKER_APPLICATION_IMAGE} as application-builder

FROM ${SPRYKER_PARENT_IMAGE} as cli-production

COPY --from=application-builder --chown=spryker:spryker /data /data

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

# Tests contain transfer declaration
COPY --chown=spryker:spryker tests ${srcRoot}/tests

ARG SPRYKER_PIPELINE
ENV SPRYKER_PIPELINE=${SPRYKER_PIPELINE}
ENV DEVELOPMENT_CONSOLE_COMMANDS=1
RUN vendor/bin/install -r ${SPRYKER_PIPELINE} -s build-development

ARG SPRYKER_BUILD_HASH='current'
ENV SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH}
ARG SPRYKER_BUILD_STAMP=''
ENV SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP}
