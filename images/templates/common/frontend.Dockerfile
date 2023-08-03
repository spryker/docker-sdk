# For brotli support you can use something like fholzer/nginx-brotli:v1.18.0
FROM ${SPRYKER_FRONTEND_IMAGE} as frontend-basic
LABEL "spryker.image" "frontend-basic"

ENV srcRoot /data

ARG DEPLOYMENT_PATH
COPY --chown=root:root --link ${DEPLOYMENT_PATH}/context/nginx/nginx.original.conf /etc/nginx/nginx.conf
COPY --chown=root:root --link ${DEPLOYMENT_PATH}/context/nginx/conf.d/frontend.default.conf.tmpl /etc/nginx/template/default.conf.tmpl
COPY --chown=root:root --link ${DEPLOYMENT_PATH}/context/nginx/conf.d/resolver.conf.tmpl /etc/nginx/template/resolver.conf.tmpl
COPY --chown=root:root --link ${DEPLOYMENT_PATH}/context/nginx/auth /etc/nginx/auth
COPY --chown=root:root --link --chmod=755 ${DEPLOYMENT_PATH}/context/nginx/entrypoint.sh /

ENV SPRYKER_DNS_RESOLVER_FLAGS="valid=10s ipv6=off"
ENV SPRYKER_DNS_RESOLVER_IP=""
ENV SPRYKER_MAINTENANCE_MODE_ENABLED="0"

ENTRYPOINT [ "/entrypoint.sh" ]

CMD ["nginx", "-g", "daemon off;"]
