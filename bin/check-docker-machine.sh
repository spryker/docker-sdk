#!/bin/bash

set -e

pushd ${BASH_SOURCE%/*} > /dev/null
. ./constants.sh
popd > /dev/null

function isDockerMachineAvailable()
{
    if [ ! -z $(echo ${DOCKER_MACHINE_NAME}) ];
    then
        return ${__TRUE};
    fi

    return ${__FALSE};
}

export -f isDockerMachineAvailable
