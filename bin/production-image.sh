#!/bin/bash

set -e

pushd ${BASH_SOURCE%/*} > /dev/null
. ./constants.sh
. ./console.sh
. ./platform.sh

VERBOSE=0 ./require.sh docker zip
popd > /dev/null

PROJECT_DIR="$( pwd )"
DEPLOYMENT_DIR="$( cd ${BASH_SOURCE%/*} >/dev/null 2>&1 && pwd )"
DEPLOYMENT_PATH="${DEPLOYMENT_DIR/$PROJECT_DIR/.}"
APPLICATIONS=(Glue Yves Zed)

function isPathExist()
{
    if [ ! -d "$1" ]; then
        return ${__FALSE}
    fi

    return ${__TRUE}
}

function isSplit()
{
    local nonSplitTemplate='"spryker/spryker":'
    local composerFilePath=${PROJECT_DIR}/composer.json

    local composerGrepResult=$(cat ${composerFilePath} | grep ${nonSplitTemplate})

    if [ -z "$composerGrepResult" ]; then
        return ${__TRUE}
    fi

    return ${__FALSE}
}

function removeTrallingSlash()
{
    local defaultSeparator=\/

    [ "$(getPlatform)" == "windows" ] && ${defaultSeparator}=\

    echo $1 | sed -e "s|${defaultSeparator}*$||g" -e "s|${defaultSeparator}${defaultSeparator}*|${defaultSeparator}|g"
}

function getDestinationPath()
{
    local destinationPath=${PROJECT_DIR}

    if isPathExist $1; then
        destinationPath=$(removeTrallingSlash $1)
    fi

    echo ${destinationPath}
}

function doProductionAssets()
{
    local tag=$1
    local destinationPath=$( getDestinationPath $2 )

    echo -e "${INFO}File name:\t\t\t\tPath:${NC}"

    for application in "${APPLICATIONS[@]}";
    do
        local assetsPath=${PROJECT_DIR}/public/${application}/assets

        if isPathExist ${assetsPath}; then
            local zipName=${application}-${tag}.zip

            zip -rq ${destinationPath}/${zipName} ${assetsPath}
            echo -e ${OK}${zipName}${NC}"\t\t\t\t"${destinationPath}/${zipName}
        fi
    done
}

function doProductionImages()
{
    local tag=${1:-${SPRYKER_DOCKER_TAG}}
    local dbEngine=${3:-${SPRYKER_DB_ENGINE}}
    local logDirectory=${4:-${SPRYKER_LOG_DIRECTORY}}

    local composerAdditionalArgs=''

    if [ -z ${GITHUB_TOKEN} ]; then
        echo -e "${WARN}Warning: GITHUB_TOKEN is not set but may be required.${NC}"
    fi

    if isSplit; then
        composerAdditionalArgs='--no-dev'
    fi

    for application in "${APPLICATIONS[@]}";
    do
        local applicationPrefix=$(echo "$application" | tr '[:upper:]' '[:lower:]')

        echo -e "${INFO}Building ${application} application with ${tag}...${NC}"

        docker build \
            -t ${SPRYKER_DOCKER_PREFIX}_${applicationPrefix}_app:${tag} \
            --progress=${PROGRESS_TYPE} \
            -f ${DEPLOYMENT_PATH}/images/prod_app/Dockerfile \
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
            --build-arg COMPOSER_ADDITIONAL_ARGS=${composerAdditionalArgs} \
            .
    done
}

export doProductionAssets
export doProductionImages
