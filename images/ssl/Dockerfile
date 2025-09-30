# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE
FROM ${SPRYKER_PARENT_IMAGE} as tls

COPY spryker_ca.crt /certs/spryker_ca.crt
ENV SPRYKER_DB_CA=/certs/spryker_ca.crt

RUN chmod 644 ${SPRYKER_DB_CA} && \
    update-ca-certificates
