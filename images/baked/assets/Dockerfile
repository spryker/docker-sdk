FROM application-codebase AS assets-builder
LABEL "spryker.image" "none"

USER root

COPY --from=node-distributive /usr/lib /usr/lib
COPY --from=node-distributive /usr/local/share /usr/local/share
COPY --from=node-distributive /usr/local/lib /usr/local/lib
COPY --from=node-distributive /usr/local/include /usr/local/include
COPY --from=node-distributive /usr/local/bin /usr/local/bin

RUN --mount=type=cache,id=aptlib,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,id=aptcache,sharing=locked,target=/var/cache/apt \
  bash -c 'if [ ! -z "$(which apt)" ]; then apt update -y && apt install -y \
     python3 \
     g++ \
     make \
     ; fi'

# Debian contains outdated Yarn package
RUN --mount=type=cache,id=aptlib,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,id=aptcache,sharing=locked,target=/var/cache/apt \
  bash -c 'if [ ! -z "$(which apt)" ]; then \
     curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
     echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
     apt update -y && apt install -y \
     yarn \
     ; fi'

RUN --mount=type=cache,id=apk,sharing=locked,target=/var/cache/apk mkdir -p /etc/apk && ln -vsf /var/cache/apk /etc/apk/cache && \
  bash -c 'if [ ! -z "$(which apk)" ]; then apk update && apk add \
     coreutils \
     ncurses \
     yarn \
     python3 \
     g++ \
     make \
     ; fi'

USER spryker

COPY --chown=spryker:spryker package.json* package-lock.json* tsconfig*.json .* *.* ${srcRoot}/
COPY --chown=spryker:spryker frontend* ${srcRoot}/frontend
COPY --chown=spryker:spryker public* ${srcRoot}/public
COPY --chown=spryker:spryker .yarn* ${srcRoot}/.yarn
COPY --chown=spryker:spryker config/Yves ${srcRoot}/config/Yves

ARG SPRYKER_ASSETS_MODE
ENV SPRYKER_ASSETS_MODE=${SPRYKER_ASSETS_MODE}
ARG SPRYKER_PIPELINE
ENV SPRYKER_PIPELINE=${SPRYKER_PIPELINE}

# This instruction is necessary to ouline dependency on precacher to make sure assets are built after
COPY --from=npm-precacher /tmp/.dependency* /tmp/

RUN --mount=type=cache,id=npm,sharing=locked,target=/home/spryker/.npm,uid=1000 \
    --mount=type=cache,id=node_modules,sharing=locked,target=${srcRoot}/node_modules \
    echo "MODE: ${SPRYKER_ASSETS_MODE}" \
    && vendor/bin/console transfer:generate \
    && vendor/bin/install -r ${SPRYKER_PIPELINE} -s build-static -s build-static-${SPRYKER_ASSETS_MODE} -vvv
