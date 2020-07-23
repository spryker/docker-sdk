# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE

FROM golang:1.12-alpine as builder
ARG VERSION=2.3.930.0
RUN set -ex && apk add --no-cache make git gcc libc-dev curl bash && \
    curl -sLO https://github.com/aws/amazon-ssm-agent/archive/${VERSION}.tar.gz && \
    mkdir -p /go/src/github.com && \
    tar xzf ${VERSION}.tar.gz && \
    mv amazon-ssm-agent-${VERSION} /go/src/github.com/amazon-ssm-agent && \
    cd /go/src/github.com/amazon-ssm-agent && \
    echo ${VERSION} > /go/src/github.com/amazon-ssm-agent/VERSION && \
    gofmt -w agent && make checkstyle || ./Tools/bin/goimports -w agent && \
    make build-linux

FROM ${SPRYKER_PARENT_IMAGE} AS application-production-dependecies

USER spryker

# Install composer modules for Spryker
COPY --chown=spryker:spryker composer.json composer.lock ${srcRoot}/
ARG COMPOSER_AUTH
ARG SPRYKER_COMPOSER_MODE
RUN --mount=type=cache,id=composer,sharing=locked,target=/home/spryker/.composer/cache,uid=1000 \
    COMPOSER_AUTH="${COMPOSER_AUTH}" composer install --no-scripts --no-interaction ${SPRYKER_COMPOSER_MODE}

FROM application-production-dependecies AS application-production-codebase

COPY --chown=spryker:spryker src ${srcRoot}/src
COPY --chown=spryker:spryker config ${srcRoot}/config
COPY --chown=spryker:spryker *.php ${srcRoot}/
# TODO: Move codebase related stuff from data folder to src. In ideal: translations in /data are needed for build below
COPY --chown=spryker:spryker data ${srcRoot}/data
RUN chmod 600 ${srcRoot}/config/Zed/*.key 2>/dev/null || true

RUN --mount=type=cache,id=composer,sharing=locked,target=/home/spryker/.composer/cache,uid=1000 \
  composer dump-autoload -o

ARG SPRYKER_PIPELINE
ENV SPRYKER_PIPELINE=${SPRYKER_PIPELINE}
ARG APPLICATION_ENV
ARG SPRYKER_DB_ENGINE
ENV APPLICATION_ENV=${APPLICATION_ENV}
ENV SPRYKER_DB_ENGINE=${SPRYKER_DB_ENGINE}

COPY --chown=spryker:spryker data ${srcRoot}/data
RUN vendor/bin/install -r ${SPRYKER_PIPELINE} -s build -s build-production -vvv

ARG SPRYKER_COMPOSER_AUTOLOAD
RUN --mount=type=cache,id=composer,sharing=locked,target=/home/spryker/.composer/cache,uid=1000 \
  composer dump-autoload ${SPRYKER_COMPOSER_AUTOLOAD}

FROM application-production-codebase AS application-production

COPY --chown=spryker:spryker public ${srcRoot}/public
COPY --chown=spryker:spryker frontend ${srcRoot}/frontend
COPY --chown=spryker:spryker .* *.* LICENSE ${srcRoot}/

USER root
RUN rm -rf /var/run/opcache/*
RUN chown -R spryker:spryker /home/spryker

ARG SPRYKER_BUILD_HASH='current'
ENV SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH}
ARG SPRYKER_BUILD_STAMP=''
ENV SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP}

RUN --mount=type=cache,id=apk,sharing=locked,target=/var/cache/apk mkdir -p /etc/apk && ln -vsf /var/cache/apk /etc/apk/cache && \
  apk update && apk add gdb

RUN set -ex && apk add --no-cache sudo ca-certificates && \
    adduser -D ssm-user && echo "ssm-user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ssm-agent-users && \
    mkdir -p /etc/amazon/ssm
COPY --from=builder /go/src/github.com/amazon-ssm-agent/bin/linux_amd64/ /usr/bin
COPY --from=builder /go/src/github.com/amazon-ssm-agent/bin/amazon-ssm-agent.json.template /etc/amazon/ssm/amazon-ssm-agent.json
COPY --from=builder /go/src/github.com/amazon-ssm-agent/bin/seelog_unix.xml /etc/amazon/ssm/seelog.xml
COPY docker/deployment/default/context/amazon-ssm-agent.json /etc/amazon/ssm/
CMD ["/usr/bin/amazon-ssm-agent"]
