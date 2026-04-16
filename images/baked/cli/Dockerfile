# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE

FROM ${SPRYKER_PARENT_IMAGE} as cli-production

USER spryker

# Install composer modules for Spryker
COPY --chown=spryker:spryker composer.json composer.lock ${srcRoot}/
ARG SPRYKER_COMPOSER_MODE
RUN --mount=type=cache,id=composer,sharing=locked,target=/home/spryker/.composer/cache,uid=1000 \
  --mount=type=ssh,uid=1000 --mount=type=secret,id=secrets-env,uid=1000 \
  set -o allexport && . /run/secrets/secrets-env && set +o allexport \
  && composer install --no-interaction ${SPRYKER_COMPOSER_MODE}

ARG SPRYKER_COMPOSER_AUTOLOAD
RUN --mount=type=cache,id=composer,sharing=locked,target=/home/spryker/.composer/cache,uid=1000 \
  composer dump-autoload ${SPRYKER_COMPOSER_AUTOLOAD}

# Tests contain transfer declaration
COPY --chown=spryker:spryker tests ${srcRoot}/tests

ENV DEVELOPMENT_CONSOLE_COMMANDS=1
RUN vendor/bin/install -r ${SPRYKER_PIPELINE} -s build-development
