ARG COMPOSER_CACHE_IMAGE

FROM ${COMPOSER_CACHE_IMAGE} AS composer-cache-import
RUN --mount=type=cache,id=composer,sharing=locked,target=/home/spryker/.composer/cache,uid=1000 \
    rm -rf /home/spryker/.composer/cache/* && \
    mv /tmp/composer_cache/cache/* /home/spryker/.composer/cache/

