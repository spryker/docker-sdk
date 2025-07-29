# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE
FROM ${SPRYKER_PARENT_IMAGE} AS application-local

# Make self-signed certificate to be trusted locally
COPY nginx/ssl/ca.crt /usr/local/share/ca-certificates
COPY . /tmp/
RUN if [ -f /tmp/certs-system.crt ]; then \
      cp /tmp/certs-system.crt /usr/local/share/ca-certificates/host-certs.crt; \
    fi
RUN update-ca-certificates
