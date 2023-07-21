USER root

RUN /usr/bin/install -d -m 777 /var/run/opcache/debug

USER spryker:spryker

ARG DEPLOYMENT_PATH
COPY --link ${DEPLOYMENT_PATH}/context/php/debug/etc/ /usr/local/etc/
