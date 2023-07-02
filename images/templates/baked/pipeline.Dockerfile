FROM application-codebase AS application-codebase-dev
LABEL "spryker.image" "none"

RUN --mount=type=cache,id=rsync,target=/rsync,uid=1000 \
  --mount=type=cache,id=vendor,target=/data/vendor,uid=1000 \
  --mount=type=cache,id=vendor-dev,target=/data/vendor.dev,uid=1000 \
  LD_LIBRARY_PATH=/rsync /rsync/rsync -ap ./vendor/ ./vendor.dev

RUN --mount=type=cache,id=composer,sharing=locked,target=/home/spryker/.composer/cache,uid=1000 \
  --mount=type=ssh,uid=1000 --mount=type=secret,id=secrets-env,uid=1000 \
  --mount=type=cache,id=vendor-dev,target=/data/vendor,uid=1000 \
  set -o allexport && . /run/secrets/secrets-env && set +o allexport \
  && rm -rf vendor/composer \
  && composer install --no-scripts --no-interaction

# -----------------------------

FROM pipeline-basic as pipeline-before-stamp
LABEL "spryker.image" "none"

USER spryker:spryker

COPY --from=application-codebase-dev --chown=spryker:spryker ${srcRoot}/composer.* ${srcRoot}/*.php ${srcRoot}/
# Install dev modules for Spryker
RUN --mount=type=cache,id=composer,sharing=locked,target=/home/spryker/.composer/cache,uid=1000 \
  --mount=type=ssh,uid=1000 --mount=type=secret,id=secrets-env,uid=1000 \
  --mount=type=cache,id=vendor-dev,target=/vendor,uid=1000 \
  --mount=type=cache,id=rsync,target=/rsync,uid=1000 \
  --mount=type=tmpfs,target=/var/run/opcache/ \
  set -o allexport && . /run/secrets/secrets-env && set +o allexport \
  && LD_LIBRARY_PATH=/rsync time /rsync/rsync -ap --chown=spryker:spryker /vendor/ ./vendor/ \
  && time composer install --no-interaction \
  && find ./vendor -type d -name ".git*" -prune -exec rm -rf {} \;
# ^ Running install again to run all scripts

COPY --from=stash-src --chown=spryker:spryker /data ${srcRoot}
COPY --chown=spryker:spryker data ${srcRoot}/data
# Tests contain transfer declaration
COPY --chown=spryker:spryker test[s] /${srcRoot}/tests

ENV DEVELOPMENT_CONSOLE_COMMANDS=1

ARG SPRYKER_COMPOSER_AUTOLOAD
RUN --mount=type=tmpfs,target=/var/run/opcache/ \
  vendor/bin/install -r ${SPRYKER_PIPELINE} -s build -s build-development \
  && composer dump-autoload ${SPRYKER_COMPOSER_AUTOLOAD}

COPY --link --chown=spryker:spryker fronten[d] ${srcRoot}/frontend
COPY --link --chown=spryker:spryker .yar[n] ${srcRoot}/.yarn
COPY --link --chown=spryker:spryker .* *.* LICENSE ${srcRoot}

FROM pipeline-before-stamp as pipeline
LABEL "spryker.image" "pipeline"

ARG SPRYKER_BUILD_HASH
ENV SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH}
ARG SPRYKER_BUILD_STAMP
ENV SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP}
