#!/bin/bash

set -e

pushd "${BASH_SOURCE%/*}" > /dev/null
. ../constants.sh
. ../console.sh
. ../build/mount.sh
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

    local volumeName=${SPRYKER_DOCKER_PREFIX}_assets

    verbose "${INFO}Creating docker volume '${volumeName}'${NC}"
    docker volume create --name="${volumeName}"

    sync start
    sync stop

    runApplicationBuild "vendor/bin/install -r docker -s build-static -s build-static-development"
}

export -f buildAssets
