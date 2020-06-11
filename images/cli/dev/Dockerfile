# syntax = docker/dockerfile:experimental
ARG SPRYKER_DOCKER_TAG
ARG SPRYKER_DOCKER_PREFIX

FROM ${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG}

# Blackfire client
RUN mkdir -p /tmp/blackfire \
    && curl -A "Docker" -L https://blackfire.io/api/v1/releases/client/linux_static/amd64 | tar zxp -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire /usr/bin/blackfire \
    && rm -Rf /tmp/blackfire

ARG SPRYKER_LOG_DIRECTORY=/var/log/spryker

ENV PATH=/data/vendor/bin:$PATH

RUN bash -c '[ ! -z "$(which apt)" ] && apt-get update && apt-get install -y \
     nodejs \
     npm \
     inotify-tools \
     netcat-openbsd \
     git \
     || true'
# Debian contains outdated NPM package
RUN bash -c '[ ! -z "$(which apt)" ] && npm install npm@latest -g || true'

RUN bash -c '[ ! -z "$(which apk)" ] && apk update && apk add \
     nodejs \
     npm \
     inotify-tools \
     netcat-openbsd \
     coreutils \
     git \
     || true'

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

ENV NEWRELIC_ENABLED=0

RUN composer global require sprymiker/autoload-cache:0.3.2 && cd ~/.composer/vendor/sprymiker/autoload-cache/ && npm install -f
