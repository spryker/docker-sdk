FROM debian:stable-slim AS tideways-deamon

ARG TIDEWAYS_ENVIRONMENT_DEFAULT=production
ENV TIDEWAYS_ENVIRONMENT=$TIDEWAYS_ENVIRONMENT_DEFAULT

RUN apt update -y && apt install -yq --no-install-recommends gnupg2 curl sudo ca-certificates

RUN echo 'deb http://s3-eu-west-1.amazonaws.com/tideways/packages debian main' > /etc/apt/sources.list.d/tideways.list && \
    curl -sS 'https://s3-eu-west-1.amazonaws.com/tideways/packages/EEB5E8F4.gpg' | apt-key add -
RUN DEBIAN_FRONTEND=noninteractive apt update -y && apt install -yq tideways-daemon && \
    apt autoremove --assume-yes && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["tideways-daemon","--hostname=tideways","--address=0.0.0.0:9135"]
