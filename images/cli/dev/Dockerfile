# syntax = docker/dockerfile:experimental
ARG SPRYKER_DOCKER_TAG
ARG SPRYKER_DOCKER_PREFIX

FROM ${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG}

ARG SPRYKER_LOG_DIRECTORY=/var/log/spryker

ENV PATH=/data/vendor/bin:$PATH

RUN bash -c '[ ! -z "$(which apt)" ] && apt-get update && apt-get install \
     nodejs \
     npm \
     inotify-tools \
     redis \
     netcat-openbsd \
     coreutils \
     git -y || true'
RUN bash -c '[ ! -z "$(which apt)" ] && npm install npm@latest -g || true'

RUN bash -c '[ ! -z "$(which apk)" ] && apk update && apk add \
     nodejs \
     npm \
     inotify-tools \
     redis \
     netcat-openbsd \
     coreutils \
     git || true'

RUN mkdir -p ${SPRYKER_LOG_DIRECTORY}
RUN chown spryker:spryker ${SPRYKER_LOG_DIRECTORY}
WORKDIR /data

ARG DEPLOYMENT_PATH
ENV DEPLOYMENT_PATH=${DEPLOYMENT_PATH}

COPY ${DEPLOYMENT_PATH}/context/cli/execute.sh /usr/local/bin/execute.sh
RUN chmod +x /usr/local/bin/execute.sh

USER spryker
