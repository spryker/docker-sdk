#!/bin/bash

set -e

pushd ${BASH_SOURCE%/*} > /dev/null
. ./path-helper.sh
popd > /dev/null

APPLICATIONS=(Glue Yves Zed)
PROJECT_DIR=${PROJECT_DIR:-$(pwd)}
SPRYKER_DOCKER_TAG=${SPRYKER_DOCKER_TAG:-'1.0'}

function getDestinationPath()
{
    local destinationPath=${PROJECT_DIR:-$(pwd)}

    if [ -d "$1" ];
    then
        destinationPath=$(removeTrailingSlash $1)
    fi

    echo ${destinationPath}
}

function doTarAssets()
{
    local tag=${1:-${SPRYKER_DOCKER_TAG}}
    local destinationPath=$( getDestinationPath $2 )

    for application in "${APPLICATIONS[@]}";
    do
        local assetsPath=${PROJECT_DIR}/public/${application}/assets/

        if [ -d "${assetsPath}" ];
        then
            local tarName=${application}-${tag}.tar
            tar czf ${destinationPath}/${tarName} -C ${assetsPath} .
        fi
    done
}

doTarAssets $@
