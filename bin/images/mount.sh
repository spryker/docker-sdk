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
APPLICATIONS=(Glue Yves Zed)

function doCliImage()
{
    verbose "${INFO}Building cli image (based on base application image)${NC}"

    docker build -t ${SPRYKER_DOCKER_PREFIX}_cli:${SPRYKER_DOCKER_TAG} \
        --build-arg SPRYKER_DOCKER_PREFIX=${SPRYKER_DOCKER_PREFIX} \
        --build-arg SPRYKER_DOCKER_TAG=${SPRYKER_DOCKER_TAG} \
        --build-arg DEPLOYMENT_PATH=${DEPLOYMENT_PATH} \
        --build-arg SPRYKER_LOG_DIRECTORY=${SPRYKER_LOG_DIRECTORY} \
        --build-arg GITHUB_TOKEN=${GITHUB_TOKEN} \
        --progress=${PROGRESS_TYPE} \
        -f ${DEPLOYMENT_PATH}/images/cli/dev/Dockerfile \
        .

    doTagByApplicationName Cli ${SPRYKER_DOCKER_PREFIX}_cli:${tag}
}

function buildBaseImages()
{
    local tag=${1:-${SPRYKER_DOCKER_TAG}}
    local dbEngine=${2:-${SPRYKER_DB_ENGINE}}
    local logDirectory=${3:-${SPRYKER_LOG_DIRECTORY}}

    if [ -z ${GITHUB_TOKEN} ];
    then
        echo -e "${WARN}Warning: GITHUB_TOKEN is not set but may be required.${NC}"
    fi

    docker build \
        -t ${SPRYKER_DOCKER_PREFIX}_app:${tag} \
        --progress=${PROGRESS_TYPE} \
        -f ${DEPLOYMENT_PATH}/images/base_dev/Dockerfile \
        --build-arg SPRYKER_PLATFORM_IMAGE=${SPRYKER_PLATFORM_IMAGE} \
        --build-arg SPRYKER_DOCKER_PREFIX=${SPRYKER_DOCKER_PREFIX} \
        --build-arg SPRYKER_DOCKER_TAG=${SPRYKER_DOCKER_TAG} \
        --build-arg USER_UID=${USER_UID:-1000} \
        --build-arg USER_GID=${USER_GID:-1000} \
        --build-arg GITHUB_TOKEN=${GITHUB_TOKEN} \
        --build-arg DEPLOYMENT_PATH=${DEPLOYMENT_PATH} \
        --build-arg APPLICATION_ENV=${APPLICATION_ENV} \
        --build-arg SPRYKER_DB_ENGINE=${dbEngine} \
        --build-arg SPRYKER_LOG_DIRECTORY=${logDirectory} \
        .

    doCliImage

    for application in "${APPLICATIONS[@]}";
    do
        doTagByApplicationName ${application} ${SPRYKER_DOCKER_PREFIX}_app:${tag}
    done
}

function tagProdLikeImages()
{
    return ${_TRUE}
}

export -f buildBaseImages
export -f tagProdLikeImages
