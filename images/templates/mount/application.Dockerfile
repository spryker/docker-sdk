FROM application-basic as application-before-stamp
LABEL "spryker.image" "none"

ARG USER_UID
RUN usermod -u ${USER_UID} spryker && find / -user 1000 -exec chown -h spryker {} \; || true;

ARG DEPLOYMENT_PATH
COPY --link ${DEPLOYMENT_PATH}/context/php/conf.d/91-opcache-dev.ini /usr/local/etc/php/conf.d

CMD [ "php-fpm", "--nodaemonize" ]
EXPOSE 9000

FROM application-before-stamp as application
LABEL "spryker.image" "application"

ARG SPRYKER_BUILD_HASH
ENV SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH}
ARG SPRYKER_BUILD_STAMP
ENV SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP}
