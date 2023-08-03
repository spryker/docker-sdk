FROM application-basic as pipeline-basic
LABEL "spryker.image" "none"

ARG SPRYKER_DB_ENGINE
RUN --mount=type=cache,id=apk,sharing=locked,target=/var/cache/apk \
  --mount=type=cache,id=aptlib,sharing=locked,target=/var/lib/apt \
  --mount=type=cache,id=aptcache,sharing=locked,target=/var/cache/apt \
  <<EOT bash -e
    if which apk; then
      mkdir -p /etc/apk
      ln -vsf /var/cache/apk /etc/apk/cache
      apk update
      apk add \
        $(if [ "${SPRYKER_DB_ENGINE}" == 'pgsql' ]; then echo 'postgresql-client'; else echo 'mysql-client'; fi) \
        yarn \
        python3 \
        jq
    else
      # Debian has outdated yarn
      curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
      echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
      apt update -y
      apt install -y \
        $(if [ "${SPRYKER_DB_ENGINE}" == 'pgsql' ]; then echo 'postgresql-client'; else echo 'default-mysql-client'; fi) \
        yarn \
        python3 \
        jq
      apt-get --purge -y autoremove
    fi
EOT

# NodeJS + NPM
COPY --link --from=node-distributive /node/usr /usr/

USER spryker:spryker
