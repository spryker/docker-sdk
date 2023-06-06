FROM alpine AS composer-cache-export

RUN --mount=type=cache,id=composer,sharing=locked,target=/home/spryker/.composer/cache,uid=1000 \
  mkdir -p /tmp/composer_cache && cp -a /home/spryker/.composer/cache /tmp/composer_cache
