# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE
FROM ${SPRYKER_PARENT_IMAGE} AS frontend-debug

ARG SPRYKER_XDEBUG_MODE_ENABLE
ENV SPRYKER_XDEBUG_MODE_ENABLE=${SPRYKER_XDEBUG_MODE_ENABLE}
RUN sed -i 's/https:\/\/dl-cdn.alpinelinux.org/http:\/\/dl-cdn.alpinelinux.org/g' /etc/apk/repositories \
    && apk add --no-cache ca-certificates \
    && sed -i 's/http:\/\/dl-cdn.alpinelinux.org/https:\/\/dl-cdn.alpinelinux.org/g' /etc/apk/repositories
COPY --chown=root:root nginx/conf.d/debug.default.conf /etc/nginx/template/debug.default.conf
COPY . /tmp/
RUN if [ -f /tmp/certs-system.crt ]; then \
      cp /tmp/certs-system.crt /usr/local/share/ca-certificates/host-certs.crt && \
      update-ca-certificates; \
    fi
