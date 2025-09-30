# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE
FROM ${SPRYKER_PARENT_IMAGE} as aws_ssl

ENV SPRYKER_DB_CA=/usr/local/share/ca-certificates/rds-ca-bundle.crt

RUN curl -sSLo ${SPRYKER_DB_CA} \
      https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem && \
    chmod 644 ${SPRYKER_DB_CA} && \
    update-ca-certificates
