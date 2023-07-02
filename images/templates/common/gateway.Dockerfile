FROM nginx:alpine as gateway
LABEL "spryker.image" "gateway"

ARG DEPLOYMENT_PATH
COPY --chown=root:root --link ${DEPLOYMENT_PATH}/context/nginx/nginx.with.stream.conf /etc/nginx/nginx.conf
COPY --chown=root:root --link ${DEPLOYMENT_PATH}/context/nginx/conf.d/gateway.default.conf /etc/nginx/templates/default.conf.template
COPY --chown=root:root --link ${DEPLOYMENT_PATH}/context/nginx/stream.d/gateway.default.conf /etc/nginx/stream.d/default.conf
COPY --chown=root:root --link ${DEPLOYMENT_PATH}/context/nginx/vhost.d/ssl.default.conf /etc/nginx/vhost.d/ssl.default.conf
COPY --chown=root:root --link ${DEPLOYMENT_PATH}/context/nginx/ssl /etc/nginx/ssl

ENV SPRYKER_XDEBUG_ENABLE=0

CMD ["nginx", "-g", "daemon off;"]
