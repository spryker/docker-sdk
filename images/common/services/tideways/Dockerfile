FROM debian:stable-slim AS tideways-daemon

ARG TIDEWAYS_ENVIRONMENT_DEFAULT=production
ENV TIDEWAYS_ENVIRONMENT=$TIDEWAYS_ENVIRONMENT_DEFAULT

RUN apt update -y && apt install -yq --no-install-recommends gnupg2 curl sudo ca-certificates wget

RUN echo 'deb https://packages.tideways.com/apt-packages-main any-version main' > /etc/apt/sources.list.d/tideways.list && \
    wget -qO - 'https://packages.tideways.com/key.gpg' | apt-key add -
RUN DEBIAN_FRONTEND=noninteractive apt update -y && apt install -yq tideways-daemon && \
    apt autoremove --assume-yes && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["tideways-daemon","--hostname=tideways","--address=0.0.0.0:9135"]
