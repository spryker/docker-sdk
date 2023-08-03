FROM node:${SPRYKER_NODE_IMAGE_VERSION}-${SPRYKER_NODE_IMAGE_DISTRO} AS node-distributive
LABEL "spryker.image" "none"

ARG SPRYKER_NPM_VERSION
RUN npm install -g npm@${SPRYKER_NPM_VERSION}

RUN <<EOT
  set -e
  mkdir -p /node/usr/lib
  mkdir -p /node/usr/local
  cp -rp /usr/lib/ /node/usr
  cp -rp /usr/local/share/ /node/usr/local
  cp -rp /usr/local/lib/ /node/usr/local
  cp -rp /usr/local/include/ /node/usr/local
  cp -rp /usr/local/bin/ /node/usr/local
EOT
