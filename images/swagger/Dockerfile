# syntax = docker/dockerfile:experimental
ARG SPRYKER_DOCKER_PREFIX
ARG SPRYKER_DOCKER_TAG
FROM ${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG} AS spryker_app

FROM swaggerapi/swagger-ui

COPY --from=spryker_app /data/src/Generated/Glue/Specification/* /var/specs/
