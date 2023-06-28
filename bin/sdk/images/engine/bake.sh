#!/bin/bash

function Images::_build::perform() {

    local folder=${1}
    local TARGET_TAG=${2:-${SPRYKER_DOCKER_TAG}}
    local destination=${3:-print}

    local -a arguments=()

    if Images::needPush; then
        arguments+=('--push')
        Console::verbose "${INFO}Building, tagging and pushing images${NC}"
    else
        Console::verbose "${INFO}Building and tagging images${NC}"
    fi

    export TARGET_TAG
    export SPRYKER_BUILD_SSH=$([ -n "${SSH_AUTH_SOCK_IN_CLI}" ] && echo 'default' || echo '')

    docker buildx bake \
        -f ${DEPLOYMENT_PATH}/images/${folder}/${destination}.docker-bake.hcl \
        "${arguments[@]}" \
        --progress="${PROGRESS_TYPE}"

}
