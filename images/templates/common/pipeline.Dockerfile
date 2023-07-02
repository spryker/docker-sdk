FROM application-basic as pipeline-basic
LABEL "spryker.image" "none"

ENV DEVELOPMENT_CONSOLE_COMMANDS=1

RUN --mount=type=cache,id=aptlib,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,id=aptcache,sharing=locked,target=/var/cache/apt \
  bash -c 'if [ ! -z "$(which apt)" ]; then apt update -y && apt install -y \
     git \
     python3 \
     jq \
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
     git \
     yarn \
     jq \
     python3 \
     ; fi'

# NodeJS + NPM
COPY --link --from=node-distributive /node/usr /usr/

USER spryker:spryker
