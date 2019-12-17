#!/bin/bash

set -e

pushd ${BASH_SOURCE%/*} > /dev/null
. ../constants.sh
. ../console.sh

../require.sh docker-machine
popd > /dev/null

function isDockerMachineCreated()
{
    local dockerMachineName=${1}

    if [ "$(docker-machine ls --filter "name=${dockerMachineName}" --format "{{.Name}}")" ];
    then
        return ${__TRUE}
    fi

    return ${__FALSE}
}

function isDockerMachineRunning()
{
    local dockerMachineName=${1}

    if [ "$(docker-machine status ${dockerMachineName})" == 'Running' ];
    then
        return ${__TRUE}
    fi

    return ${__FALSE}
}

function create()
{
    local dockerMachineName=${1}

    echo -e "${INFO}Creating ${LGRAY}"${dockerMachineName}"${INFO} machine... ${NC}"

    docker-machine create $@
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
    local dockerMachineName=${1:-${DOCKER_MACHINE_NAME}}

    if ! isDockerMachineCreated ${dockerMachineName};
    then
        create $(getDockerMachineArguments)
    else
        start ${dockerMachineName}
    fi

    evalEnv ${dockerMachineName}
}

function stopDockerMachine()
{
    local dockerMachineName=${1:-${DOCKER_MACHINE_NAME}}

    if isDockerMachineRunning ${dockerMachineName};
    then
        echo -e "${INFO}Stopping ${LGRAY}"${dockerMachineName}"${INFO} machine... ${NC}"
        stop ${dockerMachineName}
        eval $(docker-machine env -u)
    fi
}

function hostsHelper()
{
    local dockerMachineName=${1:-${DOCKER_MACHINE_NAME}}
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
    local dockerMachineName=${1:-${DOCKER_MACHINE_NAME}}

    if isDockerMachineRunning ${dockerMachineName};
    then
        echo -e "${INFO}*** Run next command for export ENV variables:${NC}"
        echo -e "${LGRAY}eval \$(docker-machine env ${dockerMachineName})${NC}"
    fi
}

function deleteDockerMachine()
{
    local dockerMachineName=${1:-${DOCKER_MACHINE_NAME}}

    if isDockerMachineCreated ${dockerMachineName};
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
