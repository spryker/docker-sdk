# syntax = docker/dockerfile:experimental
ARG SPRYKER_DOCKER_PREFIX
ARG SPRYKER_DOCKER_TAG
FROM ${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG} AS spryker_app

ENV DEVELOPMENT_CONSOLE_COMMANDS=1
RUN vendor/bin/console rest-api:generate:documentation

FROM swaggerapi/swagger-ui:3.18.3

RUN apk update && apk add bash

COPY --from=spryker_app /data/src/Generated/Glue/Specification/* /var/specs/

COPY swagger-entrypoint.sh /usr/share/entrypoint/

ENTRYPOINT ["sh", "/usr/share/entrypoint/swagger-entrypoint.sh"]
