#!/bin/bash

set -e

pushd ${BASH_SOURCE%/*} > /dev/null
. ../../constants.sh
. ../../console.sh
popd > /dev/null

function areAssetsBuilt()
{
    verbose -n "Checking assets are built..."

    [ -d public/Yves/assets ] && verbose "[BUILT]" && return ${__TRUE} || verbose "" && return ${__FALSE}
}

function buildAssets()
{
    if [ "$1" = ${IF_NOT_PERFORMED} ] && areAssetsBuilt;
    then
        return ${__TRUE}
    fi

    verbose "${INFO}Creating docker volume '${SPRYKER_DOCKER_PREFIX}_assets'${NC}"
    docker volume create --name="${SPRYKER_DOCKER_PREFIX}_assets"

    sync start
    sync stop

    runApplicationBuild "vendor/bin/install -r docker -s build-static"
}

export buildAssets
