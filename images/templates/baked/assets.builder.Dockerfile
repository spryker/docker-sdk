FROM pipeline-basic AS assets-builder
LABEL "spryker.image" "none"

USER root

RUN --mount=type=cache,id=apk,sharing=locked,target=/var/cache/apk \
  --mount=type=cache,id=aptlib,sharing=locked,target=/var/lib/apt \
  --mount=type=cache,id=aptcache,sharing=locked,target=/var/cache/apt \
  <<EOT bash -e
    if which apk; then
      mkdir -p /etc/apk
      ln -vsf /var/cache/apk /etc/apk/cache
      apk update
      apk add \
        g++ \
        make
    else
      # Debian has outdated yarn
      curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
      echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
      apt update -y
      apt install -y \
        g++ \
        make
    fi
EOT

USER spryker:spryker

# TODO exclude test-related and deploy.yml files from the scope. HOW?
COPY --chown=spryker:spryker package.json* package-lock.json* tsconfig*.json .* *.* ${srcRoot}/
COPY --chown=spryker:spryker frontend* ${srcRoot}/frontend
COPY --chown=spryker:spryker .yarn* ${srcRoot}/.yarn
COPY --from=stash-src-with-data-excluding-import --chown=spryker:spryker /data ${srcRoot}

# This instruction is necessary to ouline dependency on precacher to make sure assets are built after
COPY --from=npm-precacher /tmp/.dependency* /tmp/

ARG SPRYKER_ASSETS_MODE
RUN --mount=type=cache,id=npm,sharing=locked,target=/home/spryker/.npm,uid=1000 \
  --mount=type=cache,id=node_modules,sharing=locked,target=${srcRoot}/node_modules,uid=1000 \
  --mount=type=bind,from=application-codebase,source=/data/vendor,target=/vendor \
  --mount=type=bind,from=stash-rsync,source=/rsync,target=/rsync \
  --mount=type=tmpfs,target=/var/run/opcache/ \
  <<EOT bash -e
    LD_LIBRARY_PATH=/rsync /rsync/rsync -ap --chown=spryker:spryker /vendor/ ./vendor/ \
      --exclude '.git*/'
    echo "MODE: ${SPRYKER_ASSETS_MODE}"
    vendor/bin/console transfer:generate
    vendor/bin/install -r ${SPRYKER_PIPELINE} -s build-static -s build-static-${SPRYKER_ASSETS_MODE}
EOT
