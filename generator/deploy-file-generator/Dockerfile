# syntax = docker/dockerfile:experimental
ARG SPRYKER_PHP_VERSION=7.3

FROM spryker/php:${SPRYKER_PHP_VERSION}

WORKDIR /data
USER spryker

COPY --chown=spryker:spryker composer.json composer.lock ${srcRoot}/
RUN --mount=type=cache,id=composer,sharing=locked,target=/home/spryker/.composer/cache,uid=1000 \
    composer install --no-interaction --optimize-autoloader --no-dev

COPY --chown=spryker:spryker index.php ${srcRoot}
COPY --chown=spryker:spryker deploy-file-generator ${srcRoot}/deploy-file-generator

USER root

ARG USER_UID
RUN usermod -u ${USER_UID} spryker && find / -user 1000 -exec chown -h spryker {} \ || true;

USER spryker

CMD [ "php", "deploy-file-generator/index.php", "config" ]
