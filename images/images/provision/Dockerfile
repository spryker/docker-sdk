# syntax = docker/dockerfile:experimental
FROM alpine:latest

COPY --chown=root:root provision/ provision/
RUN chmod +x provision/run.sh

RUN apk add --no-cache --upgrade bash

# Install python/pip
ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools boto3 mysql.connector pyyaml uuid

#docker build -f docker/images/provision/Dockerfile -t provision:test docker
#docker run -it -e SPRYKER_PROJECT_NAME='default' -v ${PWD}:/project -v $HOME/.aws/credentials:/root/.aws/credentials -v $HOME/.aws/config:/root/.aws/config provision:test pre-deploy

WORKDIR provision

ENTRYPOINT ["sh", "run.sh"]
