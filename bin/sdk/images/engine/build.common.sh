#!/bin/bash

require docker

function Images::_build::perform() {

    local folder=${1}
    local TARGET_TAG=${2:-${SPRYKER_DOCKER_TAG}}
    local destination=${3:-print}

    local targetImage="${SPRYKER_DOCKER_PREFIX}_target:${SPRYKER_DOCKER_TAG}"

    Console::verbose "${INFO}Building images${NC}"

    # Primal build including all stages to fully benefit from multistage features
    Images::build::_runBuild --target "target" -t "${targetImage}"

    # Tagging all the images by running the same build targeting different stages
    source ${DEPLOYMENT_PATH}/images/${folder}/${destination}.sh

    local -a arguments=('--quiet' '--progress' 'auto')

    if [ -n "${SSH_AUTH_SOCK_IN_CLI}" ]; then
        arguments+=('--ssh' 'default')
    fi

    if Images::needPush; then
        Console::verbose "${INFO}Tagging and pushing images${NC}"
    else
        Console::verbose "${INFO}Tagging images${NC}"
    fi

    arguments+=($(Images::_build::prepareArguments))

    local targetData
    for targetData in "${TARGET_TAGS[@]}"; do
        eval "${targetData}"

        local -a tagArguments=()
        local tag
        for tag in "${TAGS[@]}"; do
            tagArguments+=('-t' "${tag}")
        done

        Console::info "${YELLOW}Target:${NC} ${TARGET}"
        Console::verbose "${YELLOW}Tags:${NC}"
        Console::verbose "${DGRAY}${TAGS[@]}${NC}"
        Console::verbose "${YELLOW}Hash:${NC}"
        Images::build::_runBuild --target "${TARGET}" "${arguments[@]}" "${tagArguments[@]}"

        Images::_build::afterTaggingAnImage "${TAGS[@]}"
    done

    docker rmi -f "${targetImage}" >/dev/null 2>&1 || true
}

function Images::build::_runBuild {

    docker build \
        -f "${DEPLOYMENT_PATH}/images/${folder}/Dockerfile" \
        "${@}" \
        --secret "id=secrets-env,src=$SECRETS_FILE_PATH" \
        --label "spryker.project=${SPRYKER_DOCKER_PREFIX}" \
        --label "spryker.revision=${SPRYKER_BUILD_HASH}" \
        --label "spryker.sdk.revision=${SPRYKER_SDK_REVISION}" \
        --build-arg "DEPLOYMENT_PATH=${DEPLOYMENT_PATH}" \
        --build-arg "SPRYKER_PLATFORM_IMAGE=${SPRYKER_PLATFORM_IMAGE}" \
        --build-arg "SPRYKER_FRONTEND_IMAGE=${SPRYKER_FRONTEND_IMAGE}" \
        --build-arg "SPRYKER_LOG_DIRECTORY=${SPRYKER_LOG_DIRECTORY}" \
        --build-arg "SPRYKER_PIPELINE=${SPRYKER_PIPELINE}" \
        --build-arg "APPLICATION_ENV=${APPLICATION_ENV}" \
        --build-arg "SPRYKER_COMPOSER_MODE=${SPRYKER_COMPOSER_MODE}" \
        --build-arg "SPRYKER_COMPOSER_AUTOLOAD=${SPRYKER_COMPOSER_AUTOLOAD}" \
        --build-arg "SPRYKER_ASSETS_MODE=${SPRYKER_ASSETS_MODE}" \
        --build-arg "SPRYKER_DB_ENGINE=${SPRYKER_DB_ENGINE}" \
        --build-arg "KNOWN_HOSTS=${KNOWN_HOSTS}" \
        --build-arg "SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH}" \
        --build-arg "SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP}" \
        --build-arg "SPRYKER_NODE_IMAGE_VERSION=${SPRYKER_NODE_IMAGE_VERSION}" \
        --build-arg "SPRYKER_NODE_IMAGE_DISTRO=${SPRYKER_NODE_IMAGE_DISTRO}" \
        --build-arg "SPRYKER_NPM_VERSION=${SPRYKER_NPM_VERSION}" \
        --build-arg "USER_UID=${USER_UID}" \
        ./ >&2
}
