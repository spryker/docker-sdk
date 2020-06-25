# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE
FROM ${SPRYKER_PARENT_IMAGE}

RUN --mount=type=cache,id=aptlib,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,id=aptcache,sharing=locked,target=/var/cache/apt \
  bash -c 'if [ ! -z "$(which apt)" ]; then apt-get update && apt-get install -y \
     supervisor \
     ; fi'

RUN --mount=type=cache,id=apk,sharing=locked,target=/var/cache/apk mkdir -p /etc/apk && ln -vsf /var/cache/apk /etc/apk/cache && \
  bash -c 'if [ ! -z "$(which apk)" ]; then apk update && apk add \
     supervisor \
     ; fi'

RUN /usr/bin/install -d -m 777 /var/run/opcache/debug
COPY php/debug/etc/ /usr/local/etc/
COPY php/debug/supervisord.conf /etc/supervisor/supervisord.conf
RUN mkdir -p /var/log/supervisor

# Make self-signed certificate to be trusted locally
COPY nginx/ssl/ca.crt /usr/local/share/ca-certificates
RUN update-ca-certificates

CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf" ]
EXPOSE 9000 9001
