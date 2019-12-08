#!/bin/bash

set -e

pushd ${BASH_SOURCE%/*} > /dev/null
. ../constants.sh
. ../console.sh
. ./abstract-docker-machine.sh

../require.sh vboxmanage
popd > /dev/null

function exportDockerMachineConfiguration()
{
    export DOCKER_MACHINE_DRIVER=virtualbox

    local defaultDockerMachineName=${SPRYKER_DOCKER_PREFIX}-${SPRYKER_DOCKER_TAG}-${DOCKER_MACHINE_DRIVER}-machine

    export DOCKER_MACHINE_NAME=${DOCKER_MACHINE_NAME:-${defaultDockerMachineName}}
    export DOCKER_MACHINE_CPU=${DOCKER_MACHINE_CPU:-2}
    export DOCKER_MACHINE_MEMORY=${DOCKER_MACHINE_MEMORY:-4096}
    export DOCKER_MACHINE_DISK_SIZE=${DOCKER_MACHINE_DISK_SIZE:-20000}
    export DOCKER_MACHINE_SHARED_FOLDER=$(pwd):$(pwd)
}

export -f exportDockerMachineConfiguration
