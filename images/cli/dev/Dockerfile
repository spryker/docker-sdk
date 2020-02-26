# syntax = docker/dockerfile:experimental
ARG SPRYKER_DOCKER_TAG
ARG SPRYKER_DOCKER_PREFIX

FROM ${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG}

ARG SPRYKER_LOG_DIRECTORY=/var/log/spryker

ENV PATH=/data/vendor/bin:$PATH

RUN apk update && apk add \
  nodejs \
  npm \
  inotify-tools \
  redis \
  netcat-openbsd \
  coreutils \
  git

RUN mkdir -p ${SPRYKER_LOG_DIRECTORY}
RUN chown spryker:spryker ${SPRYKER_LOG_DIRECTORY}
WORKDIR /data

RUN mkdir -p /host
RUN chown spryker:spryker /host

ARG DEPLOYMENT_PATH
ENV DEPLOYMENT_PATH=${DEPLOYMENT_PATH}

COPY ${DEPLOYMENT_PATH}/context/cli/execute.sh /usr/local/bin/execute.sh
RUN chmod +x /usr/local/bin/execute.sh

USER spryker

RUN composer global require spryker-sdk/autoload-cache:0.1
