#!/bin/bash

set -e

pushd "${BASH_SOURCE%/*}" > /dev/null
. ../constants.sh
. ../console.sh
. ../platform.sh
. image-builder-helper.sh

VERBOSE=0 ../require.sh docker
popd > /dev/null

PROJECT_DIR="$( pwd )"
DEPLOYMENT_DIR="$( cd ${BASH_SOURCE%/*} >/dev/null 2>&1 && pwd )"
DEPLOYMENT_PATH="${DEPLOYMENT_DIR/$PROJECT_DIR/.}"

function buildMainImage()
{
   docker build \
        -t ${SPRYKER_DOCKER_PREFIX}_main_app:${SPRYKER_DOCKER_TAG} \
        --progress=${PROGRESS_TYPE} \
        --build-arg SPRYKER_PLATFORM_IMAGE=${SPRYKER_PLATFORM_IMAGE} \
        -f ${DEPLOYMENT_PATH}/images/main/Dockerfile \
        ${DEPLOYMENT_PATH}/context/php 1>&2
}
