# syntax = docker/dockerfile:experimental
FROM alpine:latest

COPY --chown=root:root provision/ provision/
RUN chmod +x provision/run.sh

RUN apk add --no-cache --upgrade bash jq

# Install python/pip
ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools boto3 mysql.connector pyyaml uuid

WORKDIR provision

ENTRYPOINT ["sh", "run.sh"]
