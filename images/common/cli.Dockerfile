FROM pipeline-before-stamp as cli
LABEL "spryker.image" "cli"

USER root

# Blackfire client
RUN mkdir -p /tmp/blackfire \
    && architecture=$(case $(uname -m) in i386 | i686 | x86) echo "i386" ;; x86_64 | amd64) echo "amd64" ;; aarch64 | arm64 | armv8) echo "arm64" ;; *) echo "amd64" ;; esac) \
    && curl -A "Docker" -L https://blackfire.io/api/v1/releases/cli/linux/$architecture | tar zxp -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire /usr/bin/blackfire \
    && rm -Rf /tmp/blackfire

RUN --mount=type=cache,id=aptlib,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,id=aptcache,sharing=locked,target=/var/cache/apt \
  bash -c 'if [ ! -z "$(which apt)" ]; then apt update -y && apt install -y \
     netcat-openbsd \
     redis-tools \
     g++ \
     make \
     ; fi'

RUN --mount=type=cache,id=apk,sharing=locked,target=/var/cache/apk mkdir -p /etc/apk && ln -vsf /var/cache/apk /etc/apk/cache && \
  bash -c 'if [ ! -z "$(which apk)" ]; then apk update && apk add \
     netcat-openbsd \
     redis \
     g++ \
     make \
     ; fi'

USER spryker

RUN mkdir -p /home/spryker/env
ARG DEPLOYMENT_PATH
COPY --chown=spryker:spryker ${DEPLOYMENT_PATH}/context/cli /home/spryker/bin
RUN find /home/spryker/bin -type f -exec chmod +x {} \;
ENV PATH=/home/spryker/bin:$PATH

RUN mkdir -p /home/spryker/ssh-relay/ && chmod 777 /home/spryker/ssh-relay && touch /home/spryker/ssh-relay/ssh-auth.sock && chmod 666 /home/spryker/ssh-relay/ssh-auth.sock \
  && touch /tmp/stdout && touch /tmp/stderr && chmod 666 /tmp/stdout && chmod 666 /tmp/stderr

RUN mkdir -p /home/spryker/history && touch /home/spryker/history/.bash_history && chmod 0600 /home/spryker/history/.bash_history
ENV HISTFILE=/home/spryker/history/.bash_history

ENV NEWRELIC_ENABLED=0

ARG SPRYKER_BUILD_HASH
ENV SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH}
ARG SPRYKER_BUILD_STAMP
ENV SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP}
