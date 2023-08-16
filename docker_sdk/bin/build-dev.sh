#!/bin/bash

# THIS SCRIPT IS DEVELOPMENT ONLY

SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SOURCE_DIR="$(realpath "${SOURCE_DIR}/../../")"

docker build -t spryker_docker_sdk -f "${SOURCE_DIR}/docker_sdk/Dockerfile" "${SOURCE_DIR}"

docker run -it --rm \
    -v "${SOURCE_DIR}/docker_sdk/python/:/docker_sdk/python" \
    spryker_docker_sdk \
    pip install -e /docker_sdk/python --no-cache-dir
docker run -it --rm \
    -v "${SOURCE_DIR}/docker_sdk/php/:/docker_sdk/php" \
    spryker_docker_sdk \
    composer install -d /docker_sdk/php/docker-sdk --optimize-autoloader


