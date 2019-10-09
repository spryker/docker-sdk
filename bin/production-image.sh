#!/bin/bash

set -e

pushd ${BASH_SOURCE%/*} > /dev/null
. ./constants.sh
. ./console.sh
. ./platform.sh

VERBOSE=0 ./require.sh docker zip
popd > /dev/null

PROJECT_DIR="$( pwd )"
APPLICATIONS=(Glue Yves Zed)

function isPathExist()
{
    if [ ! -d "$1" ]; then
        return ${__FALSE}
    fi

    return ${__TRUE}
}

function getDestinationPath()
{
    local destinationPath=${PROJECT_DIR}

    if isPathExist $1; then
        destinationPath=${1%/}
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

export doProductionAssets
