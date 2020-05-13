# syntax = docker/dockerfile:experimental
ARG SPRYKER_DOCKER_TAG
ARG SPRYKER_DOCKER_PREFIX

FROM ${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG}

ARG SPRYKER_LOG_DIRECTORY=/var/log/spryker

ENV PATH=/data/vendor/bin:$PATH

RUN bash -c '[ ! -z "$(which apt)" ] && apt-get update && apt-get install -y \
     nodejs \
     npm \
     netcat-openbsd \
     git \
     || true'
# Debian contains outdated NPM package
RUN bash -c '[ ! -z "$(which apt)" ] && npm install npm@latest -g || true'

RUN bash -c '[ ! -z "$(which apk)" ] && apk update && apk add \
     nodejs \
     npm \
     netcat-openbsd \
     coreutils \
     git \
     || true'

RUN mkdir -p ${SPRYKER_LOG_DIRECTORY}
RUN chown spryker:spryker ${SPRYKER_LOG_DIRECTORY}
WORKDIR /data

ARG DEPLOYMENT_PATH
ENV DEPLOYMENT_PATH=${DEPLOYMENT_PATH}

COPY ${DEPLOYMENT_PATH}/context/cli/execute.sh /usr/local/bin/execute.sh
RUN chmod +x /usr/local/bin/execute.sh

USER spryker

RUN mkdir -p /home/spryker/history
RUN chown spryker:spryker /home/spryker/history

RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
COPY --chown=spryker:spryker ${DEPLOYMENT_PATH}/context/cli/shell/zsh/.zshrc /home/spryker/.zshrc
