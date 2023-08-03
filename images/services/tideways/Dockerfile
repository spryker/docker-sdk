FROM debian:stable-slim AS tidewaysDaemon
LABEL "spryker.image" "tideways-deamon"

ARG TIDEWAYS_ENVIRONMENT_DEFAULT=production
ENV TIDEWAYS_ENVIRONMENT=$TIDEWAYS_ENVIRONMENT_DEFAULT

RUN <<EOT bash -e
  export DEBIAN_FRONTEND=noninteractive
  apt update -y
  apt install -yq --no-install-recommends gnupg2 curl sudo ca-certificates wget
  echo 'deb https://packages.tideways.com/apt-packages-main any-version main' > /etc/apt/sources.list.d/tideways.list
  wget -qO - 'https://packages.tideways.com/key.gpg' | apt-key add -
  apt update -y
  apt install -yq tideways-daemon
  apt autoremove --assume-yes
  apt clean
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
EOT

ENTRYPOINT ["tideways-daemon","--hostname=tideways","--address=0.0.0.0:9135"]
