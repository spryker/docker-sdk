# syntax = docker/dockerfile:experimental
ARG SPRYKER_PHP_VERSION=8.1

FROM spryker/php:${SPRYKER_PHP_VERSION}

RUN apk add --no-cache openssl

WORKDIR /data

USER spryker


COPY --chown=spryker:spryker src/ ./src

RUN chmod 755 ./src/modules/ssl/ssl/openssl/generate.sh

USER root

ARG USER_UID
RUN usermod -u ${USER_UID} spryker && find / -user 1000 -exec chown -h spryker {} \ || true;

USER spryker

CMD [ "php", "index.php" ]
