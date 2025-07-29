# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE
ARG SPRYKER_ASSETS_BUILDER_IMAGE

FROM ${SPRYKER_ASSETS_BUILDER_IMAGE} as assets-builder
FROM ${SPRYKER_PARENT_IMAGE} as frontend-production

COPY . /tmp/
RUN if [ -f /tmp/certs-system.crt ]; then \
      cp /tmp/certs-system.crt /usr/local/share/ca-certificates/host-certs.crt && \
      update-ca-certificates; \
    fi

RUN mkdir -p /data/public && chmod 0777 /data/public
COPY --from=assets-builder --chown=root:root /data/public /data/public
