FROM pipeline-basic as pipeline-before-stamp
LABEL "spryker.image" "none"

USER spryker

# Install dev modules for Spryker
COPY --chown=spryker:spryker composer.json composer.lock ${srcRoot}/
ARG SPRYKER_COMPOSER_AUTOLOAD
RUN --mount=type=cache,id=composer,sharing=locked,target=/home/spryker/.composer/cache,uid=1000 \
  --mount=type=ssh,uid=1000 --mount=type=secret,id=secrets-env,uid=1000 \
  set -o allexport && . /run/secrets/secrets-env && set +o allexport \
  && composer install --no-interaction \
  && find ./vendor -type d -name \.git -prune -exec rm -rf {} +

# Tests contain transfer declaration
COPY --chown=spryker:spryker tests ${srcRoot}/tests

ENV DEVELOPMENT_CONSOLE_COMMANDS=1
RUN vendor/bin/install -r ${SPRYKER_PIPELINE} -s build-development

RUN composer dump-autoload ${SPRYKER_COMPOSER_AUTOLOAD}

FROM pipeline-before-stamp as pipeline
LABEL "spryker.image" "pipeline"

ARG SPRYKER_BUILD_HASH
ENV SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH}
ARG SPRYKER_BUILD_STAMP
ENV SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP}
