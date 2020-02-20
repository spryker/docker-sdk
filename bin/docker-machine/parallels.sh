#!/bin/bash

set -e

pushd ${BASH_SOURCE%/*} > /dev/null
. ../constants.sh
. ../console.sh
. ./abstract-docker-machine.sh

../require.sh prlctl
popd > /dev/null

function getDockerMachineArguments()
{
    local dockerMachineDriver=parallels
    local dockerMachineName=${SPRYKER_DOCKER_PREFIX}-${SPRYKER_DOCKER_TAG}-${dockerMachineDriver}-machine

    echo "${DOCKER_MACHINE_NAME:-${dockerMachineName}} \
        --driver=${dockerMachineDriver} \
        --parallels-cpu-count=${DOCKER_MACHINE_CPU:-2} \
        --parallels-memory=${DOCKER_MACHINE_MEMORY:-4096} \
        --parallels-disk-size=${DOCKER_MACHINE_DISK_SIZE:-20000} \
        --parallels-share-folder=$(pwd)"
}

export -f getDockerMachineArguments
