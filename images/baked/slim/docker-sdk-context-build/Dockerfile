# syntax = docker/dockerfile:1.5
ARG SPRYKER_PARENT_IMAGE

FROM ${SPRYKER_PARENT_IMAGE} as docker-sdk-context-build
# PHP configuration
COPY php/php-fpm.d/worker.conf /usr/local/etc/php-fpm.d/worker.conf
RUN sh -c "php -r 'exit(PHP_VERSION_ID > 70400 ? 1 : 0);' && sed -i '' -e 's/decorate_workers_output/;decorate_workers_output/g' /usr/local/etc/php-fpm.d/worker.conf || true"
COPY php/php.ini /usr/local/etc/php/
COPY php/conf.d/90-opcache.ini /usr/local/etc/php/conf.d

COPY php/conf.d/99-from-deploy-yaml-php.ini /usr/local/etc/php/conf.d/

# Build info
COPY --chown=spryker:spryker php/build.php /home/spryker/build.php
