# syntax = docker/dockerfile:experimental
ARG SPRYKER_PHP_VERSION=7.3

FROM spryker/php:${SPRYKER_PHP_VERSION}

RUN apk add --no-cache openssl

ARG USER_UID
RUN usermod -u ${USER_UID} spryker

WORKDIR /data
USER spryker

COPY --chown=spryker:spryker composer.json composer.lock ${srcRoot}/
RUN --mount=type=cache,id=composer,sharing=locked,target=/home/spryker/.composer/cache,uid=1000 \
    composer install --no-interaction --optimize-autoloader --no-dev

COPY --chown=spryker:spryker src ${srcRoot}/src
COPY --chown=spryker:spryker openssl ${srcRoot}/openssl
COPY --chown=spryker:spryker index.php ${srcRoot}

RUN chmod 755 ${srcRoot}/openssl/generate.sh

CMD [ "php", "index.php" ]
