# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE

FROM ${SPRYKER_PARENT_IMAGE} AS scheduler

USER root

RUN --mount=type=cache,id=aptlib,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,id=aptcache,sharing=locked,target=/var/cache/apt \
  bash -c 'if [ ! -z "$(which apt)" ]; then apt-get update && apt-get install -y \
     nodejs \
     npm \
     netcat-openbsd \
     git \
     tar \
     procps \
     tini \
     ; fi'
# Debian contains outdated NPM package
RUN --mount=type=cache,id=npm,sharing=locked,target=/root/.npm \
  bash -c 'if [ ! -z "$(which apt)" ]; then npm install npm@latest -g; fi'

RUN --mount=type=cache,id=apk,sharing=locked,target=/var/cache/apk mkdir -p /etc/apk && ln -vsf /var/cache/apk /etc/apk/cache && \
  bash -c 'if [ ! -z "$(which apk)" ]; then apk update && apk add \
     nodejs \
     npm \
     netcat-openbsd \
     coreutils \
     ncurses \
     git \
     tar \
     procps \
     tini \
     ; fi'

USER spryker

ENV PATH=/home/spryker/bin:$PATH

RUN --mount=type=cache,id=npm,sharing=locked,target=/root/.npm \
  /usr/bin/install -d -m 777 /home/spryker/cronicle \
  && cd /home/spryker/cronicle \
  && mkdir -p data logs plugins

ADD cronicle/entrypoint.sh /home/spryker/cronicle/entrypoint.sh

EXPOSE 3012 3014

ENTRYPOINT ["tini", "--"]

CMD ["sh", "/home/spryker/cronicle/entrypoint.sh"]
