FROM frontend-basic as frontend-before-stamp
LABEL "spryker.image" "none"

RUN mkdir -p ${srcRoot}/public && chmod 0777 ${srcRoot}/public
COPY --from=assets-builder --chown=root:root ${srcRoot}/public ${srcRoot}/public

FROM frontend-before-stamp as frontend
LABEL "spryker.image" "frontend"

ARG SPRYKER_BUILD_HASH
ENV SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH}
ARG SPRYKER_BUILD_STAMP
ENV SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP}

RUN mkdir -p /usr/share/nginx/ \
  && envsubst '${SPRYKER_BUILD_HASH} ${SPRYKER_BUILD_STAMP}' < /tmp/build.json > /usr/share/nginx/build.json \
  && rm -f /tmp/build.json
