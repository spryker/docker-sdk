#!/bin/bash

set -e

pushd ${BASH_SOURCE%/*} > /dev/null
. ../constants.sh
. ../console.sh

../require.sh docker-machine
popd > /dev/null

function isDockerMachineExist()
{
    local dockerMachineName=$1

    if [ "$(docker-machine ls --filter "name=${dockerMachineName}" --format "{{.Name}}")" ];
    then
        return ${__TRUE}
    fi

    return ${__FALSE}
}

function isDockerMachineRunning()
{
    local dockerMachineName=$1

    if [ "$(docker-machine status ${dockerMachineName})" == 'Running' ];
    then
        return ${__TRUE}
    fi

    return ${__FALSE}
}

function create()
{
    local dockerMachineName=${1}
    local dockerMachineDriver=${2}
    local dockerMachineCpu=${3}
    local dockerMachineMemory=${4}
    local dockerMachineDiskSize=${5}

    echo -e "${INFO}Creating ${LGRAY}"${dockerMachineName}"${INFO} machine... ${NC}"
    docker-machine create --driver=${dockerMachineDriver} \
     --${dockerMachineDriver}-share-folder="$(pwd)" \
     --${dockerMachineDriver}-cpu-count="${dockerMachineCpu}" \
     --${dockerMachineDriver}-memory="${dockerMachineMemory}" \
     --${dockerMachineDriver}-disk-size="${dockerMachineDiskSize}" \
     ${dockerMachineName}
}

function start()
{
    local dockerMachineName=${1}

    if ! isDockerMachineRunning ${dockerMachineName};
    then
        echo -e "${INFO}Starting ${LGRAY}"${dockerMachineName}"${INFO} machine... ${NC}"

        docker-machine start ${dockerMachineName} > /dev/null 2>&1 || true

        local counter=1;
        local maxCount=60;
        local interval=1;

        while : ; do
            local status=$(docker-machine ls --filter "name=${dockerMachineName}" --format "{{.Error}}")

            [ -z "${status}" ] && echo -en "${CLEAR}\r" && break
            [ ${counter} == ${maxCount} ] && echo -e "\r${WARN}${status}${NC}" && exit 1

            counter=$((counter+1))
            sleep ${interval}
        done
    else
        echo -e "${LGRAY}"${dockerMachineName}"${INFO} is starting.${NC}"
    fi
}

function stop()
{
    local dockerMachineName=${1}

    if isDockerMachineRunning ${dockerMachineName};
    then
        docker-machine stop ${dockerMachineName}
    fi
}

function evalEnv()
{
    local dockerMachineName=${1}

    if isDockerMachineRunning ${dockerMachineName};
    then
        echo -e "${INFO}Exporting ENV variables for ${LGRAY}"${dockerMachineName}"${INFO} machine. ${NC}"
        eval $(docker-machine env ${dockerMachineName})
    fi
}

function startDockerMachine()
{
    local dockerMachineName=${DOCKER_MACHINE_NAME}
    local dockerMachineDriver=${DOCKER_MACHINE_DRIVER}
    local dockerMachineCpu=${DOCKER_MACHINE_CPU}
    local dockerMachineMemory=${DOCKER_MACHINE_MEMORY}
    local dockerMachineDiskSize=${DOCKER_MACHINE_DISK_SIZE}

    if ! isDockerMachineExist ${dockerMachineName};
    then
        create ${dockerMachineName} ${dockerMachineDriver} ${dockerMachineCpu} ${dockerMachineMemory} ${dockerMachineDiskSize}
    else
        start ${dockerMachineName}
    fi

    evalEnv ${dockerMachineName}
}

function stopDockerMachine()
{
    local dockerMachineName=${DOCKER_MACHINE_NAME}

    if isDockerMachineRunning ${dockerMachineName};
    then
        echo -e "${INFO}Stopping ${LGRAY}"${dockerMachineName}"${INFO} machine... ${NC}"
        stop ${dockerMachineName}
    fi
}

function hostsHelper()
{
    local dockerMachineName=${DOCKER_MACHINE_NAME}
    local dockerMachineEndpointMap=${DOCKER_MACHINE_ENDPOINT_MAP}

    if isDockerMachineRunning ${dockerMachineName};
    then
        if [ ! -z "${dockerMachineEndpointMap}" ];
        then
            local ipAddress=$(docker-machine inspect ${dockerMachineName} --format='{{.Driver.IPAddress}}');
            echo -e "${INFO}*** \`${LGRAY}hosts${INFO}\` file should contains next configuration: ${NC}"
            echo -e "${LGRAY}${ipAddress}   ${dockerMachineEndpointMap}${NC}"
        fi
    fi
}

function envHelper()
{
    local dockerMachineName=${1}

    if isDockerMachineRunning ${dockerMachineName};
    then
        echo -e "${INFO}*** Run next command for export ENV variables:${NC}"
        echo -e "${LGRAY}eval \$(docker-machine env ${dockerMachineName})${NC}"
    fi
}

function deleteDockerMachine()
{
    local dockerMachineName=${DOCKER_MACHINE_NAME}

    if isDockerMachineExist ${dockerMachineName};
    then
        docker-machine rm ${dockerMachineName}
        eval $(docker-machine env -u)
    fi
}

export -f startDockerMachine
export -f stopDockerMachine
export -f deleteDockerMachine
export -f hostsHelper
export -f envHelper
