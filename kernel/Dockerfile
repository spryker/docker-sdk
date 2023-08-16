FROM spryker_docker_sdk_codebase

RUN apk add --no-cache bash

WORKDIR /

COPY kernel /kernel

RUN pip3 install --no-cache --upgrade pip setuptools
RUN pip3 install -e /kernel --no-cache-dir

ENTRYPOINT ["python3", "-m", "kernel"]
