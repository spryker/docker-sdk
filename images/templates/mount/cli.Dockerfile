FROM cli-basic as cli
LABEL "spryker.image" "cli"

USER root

ARG USER_UID
RUN usermod -u ${USER_UID} spryker && find / -user 1000 -exec chown -h spryker {} \; || true;

ARG DEPLOYMENT_PATH
COPY --link ${DEPLOYMENT_PATH}/context/php/conf.d/91-opcache-dev.ini /usr/local/etc/php/conf.d

USER spryker:spryker

ARG SPRYKER_BUILD_HASH
ENV SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH}
ARG SPRYKER_BUILD_STAMP
ENV SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP}
