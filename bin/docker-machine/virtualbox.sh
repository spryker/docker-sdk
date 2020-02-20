#!/bin/bash

set -e

pushd ${BASH_SOURCE%/*} > /dev/null
. ../constants.sh
. ../console.sh
. ./abstract-docker-machine.sh

../require.sh vboxmanage
popd > /dev/null

function getDockerMachineArguments()
{
    local dockerMachineDriver=virtualbox
    local dockerMachineName=${SPRYKER_DOCKER_PREFIX}-${SPRYKER_DOCKER_TAG}-${dockerMachineDriver}-machine

    echo "${DOCKER_MACHINE_NAME:-${dockerMachineName}} \
        --driver=${dockerMachineDriver} \
        --virtualbox-cpu-count=${DOCKER_MACHINE_CPU:-2} \
        --virtualbox-memory=${DOCKER_MACHINE_MEMORY:-4096} \
        --virtualbox-disk-size=${DOCKER_MACHINE_DISK_SIZE:-20000} \
        --virtualbox-share-folder=$(pwd):$(pwd)"
}

export -f getDockerMachineArguments
