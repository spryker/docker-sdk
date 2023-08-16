# syntax = docker/dockerfile:experimental
ARG SPRYKER_PHP_VERSION=8.1

FROM spryker/php:${SPRYKER_PHP_VERSION}

RUN apk add --no-cache bash openssl python3 py3-pip

WORKDIR /docker_sdk

COPY ./docker_sdk/php/docker-sdk /docker_sdk/php/docker-sdk
RUN composer install -d /docker_sdk/php/docker-sdk --no-interaction --optimize-autoloader

COPY ./docker_sdk/python/docker_sdk /docker_sdk/python/docker_sdk
COPY ./docker_sdk/python/setup.py /docker_sdk/python/setup.py

RUN pip3 install --no-cache --upgrade pip setuptools
RUN pip3 install -e /docker_sdk/python --no-cache-dir






