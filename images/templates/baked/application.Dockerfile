FROM application-basic  AS application-codebase
LABEL "spryker.image" "none"

USER spryker

# Install composer modules for Spryker
COPY --chown=spryker:spryker composer.json composer.lock ${srcRoot}/
ARG SPRYKER_COMPOSER_MODE
RUN --mount=type=cache,id=composer,sharing=locked,target=/home/spryker/.composer/cache,uid=1000 \
  --mount=type=ssh,uid=1000 --mount=type=secret,id=secrets-env,uid=1000 \
  set -o allexport && . /run/secrets/secrets-env && set +o allexport \
  && composer install --no-scripts --no-interaction ${SPRYKER_COMPOSER_MODE} \
  && find ./vendor -type d -name ".git*" -prune -exec sh -c 'cd {} && rm -rf -- ./*' \;

COPY --chown=spryker:spryker src ${srcRoot}/src
COPY --chown=spryker:spryker config ${srcRoot}/config
COPY --chown=spryker:spryker *.php ${srcRoot}/
# TODO: Move codebase related stuff from data folder to src. In ideal: translations in /data are needed for build below
COPY --chown=spryker:spryker data ${srcRoot}/data
RUN chmod 600 ${srcRoot}/config/Zed/*.key 2>/dev/null || true

ENV PATH=${srcRoot}/vendor/bin:$PATH

ARG APPLICATION_ENV
ENV APPLICATION_ENV=${APPLICATION_ENV}

FROM application-codebase AS application-before-stamp
LABEL "spryker.image" "none"

USER spryker

ARG SPRYKER_PIPELINE
ENV SPRYKER_PIPELINE=${SPRYKER_PIPELINE}
ARG SPRYKER_DB_ENGINE
ENV SPRYKER_DB_ENGINE=${SPRYKER_DB_ENGINE}

COPY --chown=spryker:spryker data ${srcRoot}/data
RUN vendor/bin/install -r ${SPRYKER_PIPELINE} -s build -s build-production

ARG SPRYKER_COMPOSER_AUTOLOAD
RUN composer dump-autoload ${SPRYKER_COMPOSER_AUTOLOAD}

COPY --chown=spryker:spryker public ${srcRoot}/public
COPY --chown=spryker:spryker frontend ${srcRoot}/frontend
COPY --chown=spryker:spryker .yarn* ${srcRoot}/.yarn
COPY --chown=spryker:spryker .* *.* LICENSE ${srcRoot}/

USER root
RUN rm -rf /var/run/opcache/*
RUN chown -R spryker:spryker /home/spryker

CMD [ "php-fpm", "--nodaemonize" ]
EXPOSE 9000

FROM application-before-stamp AS application
LABEL "spryker.image" "application"

ARG SPRYKER_BUILD_HASH
ENV SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH}
ARG SPRYKER_BUILD_STAMP
ENV SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP}
