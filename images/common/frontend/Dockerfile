# For brotli support you can use something like fholzer/nginx-brotli:v1.18.0
FROM ${SPRYKER_FRONTEND_IMAGE} as frontend-basic
LABEL "spryker.image" "frontend-basic"

ENV srcRoot /data

RUN mkdir -p /etc/nginx/template/ && chmod 0777 /etc/nginx/template/
ARG DEPLOYMENT_PATH
COPY --chown=root:root ${DEPLOYMENT_PATH}/context/nginx/nginx.original.conf /etc/nginx/nginx.conf
COPY --chown=root:root ${DEPLOYMENT_PATH}/context/nginx/conf.d/frontend.default.conf.tmpl /etc/nginx/template/default.conf.tmpl
COPY --chown=root:root ${DEPLOYMENT_PATH}/context/nginx/conf.d/resolver.conf.tmpl /etc/nginx/template/resolver.conf.tmpl
COPY --chown=root:root ${DEPLOYMENT_PATH}/context/nginx/auth /etc/nginx/auth
COPY --chown=root:root ${DEPLOYMENT_PATH}/context/nginx/entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENV SPRYKER_DNS_RESOLVER_FLAGS="valid=10s ipv6=off"
ENV SPRYKER_DNS_RESOLVER_IP=""
ENV SPRYKER_MAINTENANCE_MODE_ENABLED="0"

COPY --chown=root:root ${DEPLOYMENT_PATH}/context/nginx/build.json /tmp/build.json

ENTRYPOINT [ "/entrypoint.sh" ]

CMD ["nginx", "-g", "daemon off;"]
