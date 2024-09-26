# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE
ARG SPRYKER_ASSETS_BUILDER_IMAGE

FROM ${SPRYKER_ASSETS_BUILDER_IMAGE} as assets-builder

RUN ls -R /data/public/Yves

FROM ${SPRYKER_PARENT_IMAGE} AS application-assets

RUN rm -rf /data/public
COPY --from=assets-builder --chown=root:root /data/public /data/public
