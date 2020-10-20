# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE
FROM ${SPRYKER_PARENT_IMAGE} AS application-local

# Make self-signed certificate to be trusted locally
COPY nginx/ssl/ca.crt /usr/local/share/ca-certificates
RUN update-ca-certificates
