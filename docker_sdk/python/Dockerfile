FROM python:3.9-alpine

RUN apk add --no-cache bash

WORKDIR /docker_sdk

COPY docker_sdk /docker_sdk/python/docker_sdk
COPY setup.py /docker_sdk/python/setup.py

RUN pip3 install --no-cache --upgrade pip setuptools
RUN pip3 install -e /docker_sdk/python --no-cache-dir
