#!/bin/bash

require docker

import sdk/images/destination/print.sh

function Images::pull() {
    docker pull "${SPRYKER_PLATFORM_IMAGE}" || true
}

function Images::destroy() {
    Console::verbose "Removing all Spryker images"

    # ${XARGS_NO_RUN_IF_EMPTY} must be without quotes
    # shellcheck disable=SC2086
    docker images --filter "label=spryker.project=${SPRYKER_DOCKER_PREFIX}" --format "{{.ID}}" | xargs ${XARGS_NO_RUN_IF_EMPTY} docker rmi -f 2>/dev/null
    docker images --filter "reference=spryker_docker_sdk*" --format "{{.ID}}" | xargs ${XARGS_NO_RUN_IF_EMPTY} docker rmi -f 2>/dev/null
    docker rmi -f "${SPRYKER_PLATFORM_IMAGE}" 2>/dev/null || true
}

function Images::_build() {

    # Checking availability of docker bake
    if docker buildx --help | grep bake >/dev/null 2>&1; then
        import sdk/images/engine/bake.sh
    else
        import sdk/images/engine/build.sh
    fi

    # Using temporary file for secrets as `docker secret` is only available for swarm mode.
    function Images::_prepareSecrets() {
        env - "${SECRETS_ENVIRONMENT[@]}" env > "${SECRETS_FILE_PATH}"
    }

    Images::_prepareSecrets
    Registry::Trap::addExitHook 'removeBuildSecrets' "rm -f ${SECRETS_FILE_PATH}"

    Images::_build::perform "${@}"

    Registry::Trap::releaseExitHook 'removeBuildSecrets'
}

function Images::print() {

    local TARGET_TAG=${1:-${SPRYKER_DOCKER_TAG}}
    local destination=${2:-print}

    source ${DEPLOYMENT_PATH}/images/export/${destination}.sh

    local imageData
    for imageData in "${IMAGE_TAGS[@]}"; do
        eval "${imageData}"

        for tag in "${TAGS[@]}"; do
            echo -e "$IMAGE $tag"
        done

    done
}
