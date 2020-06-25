# syntax = docker/dockerfile:experimental
ARG SPRYKER_GATEWAY_IMAGE=nginx:alpine

FROM ${SPRYKER_GATEWAY_IMAGE} as gateway

COPY --chown=root:root nginx/nginx.with.stream.conf /etc/nginx/nginx.conf
COPY --chown=root:root nginx/conf.d/gateway.default.conf /etc/nginx/conf.d/default.conf
COPY --chown=root:root nginx/stream.d/gateway.default.conf /etc/nginx/stream.d/default.conf
COPY --chown=root:root nginx/vhost.d/ssl.default.conf /etc/nginx/vhost.d/ssl.default.conf
COPY --chown=root:root nginx/ssl /etc/nginx/ssl

CMD ["nginx", "-g", "daemon off;"]
