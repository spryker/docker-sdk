# syntax = docker/dockerfile:1.5
ARG SPRYKER_PARENT_IMAGE

ARG SPRYKER_NODE_IMAGE_VERSION
ARG SPRYKER_NODE_IMAGE_DISTRO
FROM node:${SPRYKER_NODE_IMAGE_VERSION}-${SPRYKER_NODE_IMAGE_DISTRO} AS node
ARG SPRYKER_NPM_VERSION
RUN npm install -g npm@${SPRYKER_NPM_VERSION}


FROM ${SPRYKER_PARENT_IMAGE} AS assets-builder

# NodeJS + NPM
COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/share /usr/local/share
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

USER spryker

COPY --chown=spryker:spryker frontend* ${srcRoot}/frontend
COPY --chown=spryker:spryker config*/Yves* ${srcRoot}/config/Yves
COPY --chown=spryker:spryker package.json* package-lock.json* tsconfig*.json ${srcRoot}/

ARG SPRYKER_ASSETS_MODE='production'
ENV SPRYKER_ASSETS_MODE=${SPRYKER_ASSETS_MODE}
ARG SPRYKER_PIPELINE
ENV SPRYKER_PIPELINE=${SPRYKER_PIPELINE}

RUN --mount=type=cache,id=npm-cache,sharing=locked,target=/home/spryker/.npm,uid=1000 --mount=type=cache,id=npm-modules,sharing=locked,target=/data/node_modules,uid=1000 \
    sh -c 'if [ -f ${srcRoot}/package.json ]; then npm install --prefer-offline || npm ci --prefer-offline; fi'

RUN --mount=type=cache,id=npm-cache,sharing=locked,target=/home/spryker/.npm,uid=1000 --mount=type=cache,id=npm-modules,sharing=locked,target=/data/node_modules,uid=1000 \
    echo "BUILD HASH: ${SPRYKER_BUILD_HASH}" \
    && echo "MODE: ${SPRYKER_ASSETS_MODE}" \
    && vendor/bin/install -r ${SPRYKER_PIPELINE} -s build-static-${SPRYKER_ASSETS_MODE} -vvv
