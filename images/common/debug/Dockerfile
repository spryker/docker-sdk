# syntax = docker/dockerfile:experimental
ARG SPRYKER_APPLICATION_IMAGE
FROM ${SPRYKER_APPLICATION_IMAGE}

RUN --mount=type=cache,id=aptlib,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,id=aptcache,sharing=locked,target=/var/cache/apt \
  bash -c 'if [ ! -z "$(which apt)" ]; then apt-get update && apt-get install -y \
     supervisor \
     ; fi'

RUN --mount=type=cache,id=apk,sharing=locked,target=/var/cache/apk ln -vs /var/cache/apk /etc/apk/cache && \
  bash -c 'if [ ! -z "$(which apk)" ]; then apk update && apk add \
     supervisor \
     ; fi'

RUN /usr/bin/install -d -m 777 /var/run/opcache/debug
COPY debug/etc/ /usr/local/etc/
COPY debug/supervisord.conf /etc/supervisor/supervisord.conf
RUN mkdir -p /var/log/supervisor

CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf" ]
EXPOSE 9000 9001
