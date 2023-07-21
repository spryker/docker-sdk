USER root

RUN --mount=type=cache,id=aptlib,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,id=aptcache,sharing=locked,target=/var/cache/apt \
  bash -c 'if [ ! -z "$(which apt)" ]; then apt update -y && apt install -y \
     supervisor \
     ; fi'

RUN --mount=type=cache,id=apk,sharing=locked,target=/var/cache/apk mkdir -p /etc/apk && ln -vsf /var/cache/apk /etc/apk/cache && \
  bash -c 'if [ ! -z "$(which apk)" ]; then apk update && apk add \
     supervisor \
     ; fi'

ARG DEPLOYMENT_PATH
COPY --link ${DEPLOYMENT_PATH}/context/php/debug/etc/ /usr/local/etc/
COPY --link ${DEPLOYMENT_PATH}/context/php/debug/supervisord.conf /etc/supervisor/supervisord.conf

RUN /usr/bin/install -d -m 777 /var/run/opcache/debug \
  && mkdir -p /var/log/supervisor \
  && bash -c "php -r 'exit(PHP_VERSION_ID > 70400 ? 1 : 0);' && sed -i '' -e 's/decorate_workers_output/;decorate_workers_output/g' /usr/local/etc/debug.php-fpm.conf/worker.conf || true"

CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf" ]
EXPOSE 9000 9001
