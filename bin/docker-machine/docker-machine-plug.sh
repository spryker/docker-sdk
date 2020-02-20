#!/bin/bash

set -e

pushd ${BASH_SOURCE%/*} > /dev/null
. ../constants.sh
popd > /dev/null

function startDockerMachine()
{
    return ${__TRUE};
}

function stopDockerMachine()
{
    return ${__TRUE};
}

function deleteDockerMachine()
{
    return ${__TRUE};
}

function hostsHelper()
{
    return ${__TRUE};
}

function envHelper()
{
    return ${__TRUE}
}

function getDockerMachineArguments()
{
    return ${__TRUE}
}

export -f startDockerMachine
export -f stopDockerMachine
export -f deleteDockerMachine
export -f hostsHelper
export -f envHelper
export -f getDockerMachineArguments
