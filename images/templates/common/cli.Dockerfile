FROM ${SPRYKER_PLATFORM_IMAGE} as cli-dependencies
LABEL "spryker.image" "none"

USER root

# Blackfire client
RUN <<EOT bash -e -x
  mkdir -p /tmp/blackfire
  export CPU_ARCHITECTURE=$(case $(uname -m) in i386 | i686 | x86) echo "i386" ;; x86_64 | amd64) echo "amd64" ;; aarch64 | arm64 | armv8) echo "arm64" ;; *) echo "amd64" ;; esac)
  curl -A "Docker" -L "https://blackfire.io/api/v1/releases/cli/linux/\$CPU_ARCHITECTURE" | tar zxp -C /tmp/blackfire
  mv /tmp/blackfire/blackfire /usr/bin/blackfire
  rm -Rf /tmp/blackfire
EOT

FROM pipeline-before-stamp as cli-basic
LABEL "spryker.image" "none"

USER root

COPY --from=cli-dependencies --link --chmod=755 /usr/bin/blackfire /usr/bin/blackfire

RUN --mount=type=cache,id=apk,sharing=locked,target=/var/cache/apk \
  --mount=type=cache,id=aptlib,sharing=locked,target=/var/lib/apt \
  --mount=type=cache,id=aptcache,sharing=locked,target=/var/cache/apt \
  <<EOT bash -e
    if which apk; then
      mkdir -p /etc/apk
      ln -vsf /var/cache/apk /etc/apk/cache
      apk update
      apk add \
        netcat-openbsd \
        redis \
        g++ \
        make
    else
      apt update -y
      apt install -y \
        netcat-openbsd \
        redis-tools \
        g++ \
        make
      apt-get --purge -y autoremove
    fi
EOT

USER spryker:spryker

ENV PATH=/home/spryker/bin:$PATH
ENV HISTFILE=/home/spryker/history/.bash_history
ENV NEWRELIC_ENABLED=0

ARG DEPLOYMENT_PATH
COPY --chown=spryker:spryker --link --chmod=755 ${DEPLOYMENT_PATH}/context/cli /home/spryker/bin

RUN <<EOT bash -e
  mkdir -p /home/spryker/env \

  mkdir -p /home/spryker/ssh-relay/
  chmod 777 /home/spryker/ssh-relay
  touch /home/spryker/ssh-relay/ssh-auth.sock
  chmod 666 /home/spryker/ssh-relay/ssh-auth.sock \

  touch /tmp/stdout
  touch /tmp/stderr
  chmod 666 /tmp/stdout
  chmod 666 /tmp/stderr \

  mkdir -p /home/spryker/history
  touch /home/spryker/history/.bash_history
  chmod 0600 /home/spryker/history/.bash_history
EOT
