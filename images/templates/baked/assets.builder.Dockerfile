FROM application-basic AS assets-builder
LABEL "spryker.image" "none"

USER root

COPY --from=node-distributive /node/usr /usr/

RUN --mount=type=cache,id=aptlib,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,id=aptcache,sharing=locked,target=/var/cache/apt \
  bash -c 'if [ ! -z "$(which apt)" ]; then apt update -y && apt install -y \
     python3 \
     g++ \
     make \
     ; \
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

USER spryker:spryker

COPY --chown=spryker:spryker package.json* package-lock.json* tsconfig*.json .es*.* .npm* ${srcRoot}/
COPY --chown=spryker:spryker frontend* ${srcRoot}/frontend
COPY --chown=spryker:spryker .yarn* ${srcRoot}/.yarn
COPY --from=stash-src-with-data-excluding-import --chown=spryker:spryker /data ${srcRoot}

# This instruction is necessary to ouline dependency on precacher to make sure assets are built after
COPY --from=npm-precacher /tmp/.dependency* /tmp/
COPY --from=application-codebase /tmp/.dependency* /tmp/

ARG SPRYKER_ASSETS_MODE
RUN --mount=type=cache,id=npm,sharing=locked,target=/home/spryker/.npm,uid=1000 \
  --mount=type=cache,id=node_modules,sharing=locked,target=${srcRoot}/node_modules,uid=1000 \
  --mount=type=cache,id=vendor,target=/data/vendor,uid=1000 \
  echo "MODE: ${SPRYKER_ASSETS_MODE}" \
  && vendor/bin/console transfer:generate \
  && vendor/bin/install -r ${SPRYKER_PIPELINE} -s build-static -s build-static-${SPRYKER_ASSETS_MODE}
