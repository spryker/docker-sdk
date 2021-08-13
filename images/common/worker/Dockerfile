# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE

FROM ${SPRYKER_PARENT_IMAGE} AS scheduler

ENV NODEJS_VERSION='12'
ENV CRONICLE_REPO='https://github.com/spryker-sdk/Cronicle.git'
ENV CRONICLE_BRANCH='feature/sc-5888/master-light-weight-scheduler'
USER root

RUN --mount=type=cache,id=aptlib,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,id=aptcache,sharing=locked,target=/var/cache/apt \
  bash -c 'if [ ! -z "$(which apt)" ]; then curl -fsSL https://deb.nodesource.com/setup_$NODEJS_VERSION.x | bash - ; \
     apt-get update && apt-get install -y \
     nodejs \
     netcat-openbsd \
     git \
     tar \
     procps \
     tini \
     ; fi'

RUN --mount=type=cache,id=apk,sharing=locked,target=/var/cache/apk mkdir -p /etc/apk && ln -vsf /var/cache/apk /etc/apk/cache && \
  bash -c 'if [ ! -z "$(which apk)" ]; then curl -fsSL https://rpm.nodesource.com/setup_$NODEJS_VERSION.x | bash - ; \
     apk update && apk add \
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
  /usr/bin/install -d -m 777 /home/spryker/ \
  && cd /home/spryker \
  && git clone -b $CRONICLE_BRANCH $CRONICLE_REPO cronicle\
  && cd cronicle \
  && npm i \
  && mkdir -p data logs plugins

ADD cronicle/entrypoint.sh /home/spryker/cronicle/entrypoint.sh

EXPOSE 3012 3014

ENTRYPOINT ["tini", "--"]

CMD ["sh", "/home/spryker/cronicle/entrypoint.sh"]
