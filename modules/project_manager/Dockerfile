FROM spryker_docker_sdk_codebase

RUN apk add --no-cache bash

WORKDIR /

COPY ./modules/project_manager /modules/project_manager

RUN pip3 install --no-cache --upgrade pip setuptools
RUN pip3 install -e /modules/project_manager --no-cache-dir

ENTRYPOINT ["python3", "-m", "project_manager"]
