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

function Images::_checkBuildxVersion() {
    min_version=${1}
    version_regex="v([0-9]+\.[0-9]+\.[0-9]+)"
    actual_version=$([[ $(docker buildx version) =~ $version_regex ]] && echo "${BASH_REMATCH[1]}")
    greater_version=$(printf "%s\n%s\n" "${actual_version}" "${min_version}" | sort -t '.' -k 1,1 -k 2,2 -k 3,3 -g | tail -n 1)
    if [ "$min_version" == "$greater_version" ]; then
        return "${FALSE}"
    fi
}

function Images::_build() {

    # Checking availability of docker bake or buildx
    if docker buildx >/dev/null 2>&1; then
        if Images::_checkBuildxVersion "0.6.99"; then
            import sdk/images/engine/bake.sh
        else
            import sdk/images/engine/buildx.sh
            Console::warn 'Warning! Upgrade `buildx` docker plugin to the latest version for better performance'
        fi
    else
        import sdk/images/engine/build.sh
        Console::warn 'Warning! Install `buildx` docker plugin for better performance'
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
