# syntax = docker/dockerfile:experimental
ARG SPRYKER_DOCKER_TAG
ARG SPRYKER_DOCKER_PREFIX
# For brotli support you can use something like fholzer/nginx-brotli:v1.18.0
ARG SPRYKER_FRONTEND_IMAGE=nginx:alpine

FROM ${SPRYKER_DOCKER_PREFIX}_cli:${SPRYKER_DOCKER_TAG} AS builder

USER spryker

COPY package.json package-lock.json ${srcRoot}/
COPY frontend ${srcRoot}/frontend
COPY tsconfig.json ${srcRoot}/
COPY config/Yves ${srcRoot}/config/Yves

ARG SPRYKER_ASSETS_MODE='development'
ENV SPRYKER_ASSETS_MODE=${SPRYKER_ASSETS_MODE}

RUN --mount=type=cache,id=npm,sharing=locked,target=/root/.npm \
    echo "BUILD HASH: ${SPRYKER_BUILD_HASH}" \
    && echo "MODE: ${SPRYKER_ASSETS_MODE}" \
    && vendor/bin/install -r docker -s build-static -s build-static-${SPRYKER_ASSETS_MODE} -vvv

FROM ${SPRYKER_FRONTEND_IMAGE} as frontend

RUN mkdir -p /data/public && chmod 0777 /data/public
COPY --from=builder --chown=root:root /data/public /data/public

ARG DEPLOYMENT_PATH

RUN mkdir -p /etc/nginx/template/ && chmod 0777 /etc/nginx/template/
COPY --chown=root:root ${DEPLOYMENT_PATH}/context/nginx/nginx.original.conf /etc/nginx/nginx.conf
COPY --chown=root:root ${DEPLOYMENT_PATH}/context/nginx/frontend/default.conf.tmpl /etc/nginx/template/
COPY --chown=root:root ${DEPLOYMENT_PATH}/context/nginx/auth /etc/nginx/auth
COPY --chown=root:root ${DEPLOYMENT_PATH}/context/nginx/frontend/entrypoint.sh /
RUN chmod +x /entrypoint.sh

ARG SPRYKER_BUILD_HASH='current'
ENV SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH}
ARG SPRYKER_BUILD_STAMP=''
ENV SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP}

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["nginx", "-g", "daemon off;"]
