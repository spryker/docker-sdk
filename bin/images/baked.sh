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

function doBaseImage()
{
    local dbEngine=${1:-${SPRYKER_DB_ENGINE}}
    local logDirectory=${2:-${SPRYKER_LOG_DIRECTORY}}

    docker build \
        -t ${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG} \
        --progress=${PROGRESS_TYPE} \
        -f ${DEPLOYMENT_PATH}/images/base_app/Dockerfile \
        --build-arg SPRYKER_PLATFORM_IMAGE=${SPRYKER_PLATFORM_IMAGE} \
        --build-arg SPRYKER_DOCKER_PREFIX=${SPRYKER_DOCKER_PREFIX} \
        --build-arg SPRYKER_DOCKER_TAG=${SPRYKER_DOCKER_TAG} \
        --build-arg USER_UID=${USER_UID:-1000} \
        --build-arg USER_GID=${USER_GID:-1000} \
        --build-arg GITHUB_TOKEN=${GITHUB_TOKEN} \
        --build-arg KNOWN_HOSTS="${KNOWN_HOSTS}" \
        --build-arg DEPLOYMENT_PATH=${DEPLOYMENT_PATH} \
        --build-arg APPLICATION_ENV=${APPLICATION_ENV} \
        --build-arg SPRYKER_DB_ENGINE=${dbEngine} \
        --build-arg SPRYKER_LOG_DIRECTORY=${logDirectory} \
        --build-arg SPRYKER_COMPOSER_MODE=${SPRYKER_COMPOSER_MODE} \
        --build-arg SPRYKER_COMPOSER_AUTOLOAD=${SPRYKER_COMPOSER_AUTOLOAD} \
        --build-arg BLACKFIRE_ENABLED=${BLACKFIRE_ENABLED:-1} \
        . 1>&2
}

function doCliImage()
{
    if [ -z ${GITHUB_TOKEN} ];
    then
        echo -e "${WARN}Warning: GITHUB_TOKEN is not set but may be required.${NC}"
    fi

    docker build -t ${SPRYKER_DOCKER_PREFIX}_cli:${SPRYKER_DOCKER_TAG} \
        --build-arg SPRYKER_DOCKER_PREFIX=${SPRYKER_DOCKER_PREFIX} \
        --build-arg SPRYKER_DOCKER_TAG=${SPRYKER_DOCKER_TAG} \
        --build-arg DEPLOYMENT_PATH=${DEPLOYMENT_PATH} \
        --build-arg SPRYKER_LOG_DIRECTORY=${SPRYKER_LOG_DIRECTORY} \
        --build-arg GITHUB_TOKEN=${GITHUB_TOKEN} \
        --progress=${PROGRESS_TYPE} \
        -f ${DEPLOYMENT_PATH}/images/cli/demo/Dockerfile \
        .
}

function buildBaseImages()
{
    local dbEngine=${2:-${SPRYKER_DB_ENGINE}}
    local logDirectory=${3:-${SPRYKER_LOG_DIRECTORY}}
    local baseImageName=${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG}

    if [ -z ${GITHUB_TOKEN} ];
    then
        echo -e "${WARN}Warning: GITHUB_TOKEN is not set but may be required.${NC}"
    fi

    doBaseImage ${dbEngine} ${logDirectory}
    doCliImage
}

function tagProdLikeImages()
{
    local tag=${1:-${SPRYKER_DOCKER_TAG}}

    echo -e "${INFO}The following images have been prepared${NC}:" > /dev/stderr

    doTagByApplicationName Cli ${SPRYKER_DOCKER_PREFIX}_cli:${tag} ${SPRYKER_DOCKER_PREFIX}_cli:${SPRYKER_DOCKER_TAG}

    for application in "${APPLICATIONS[@]}";
    do
        doTagByApplicationName ${application} ${SPRYKER_DOCKER_PREFIX}_app:${tag} ${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG}
    done
}

export -f buildBaseImages
export -f tagProdLikeImages
