#!/bin/bash

require docker

function Images::pull() {
    docker pull "${SPRYKER_PLATFORM_IMAGE}" || true
}

function Images::destroy() {
    Console::verbose "Removing all Spryker images"

    docker images --filter "reference=${SPRYKER_DOCKER_PREFIX}_*:${SPRYKER_DOCKER_TAG}" --format "{{.ID}}" | xargs docker rmi -f

    docker rmi -f "${SPRYKER_DOCKER_PREFIX}_cli" || true
    docker rmi -f "${SPRYKER_DOCKER_PREFIX}_app" || true
    docker rmi -f "${SPRYKER_PLATFORM_IMAGE}" || true
}

function Images::buildApp() {
    local folder=${1}
    local baseAppImage="${SPRYKER_DOCKER_PREFIX}_base_app:${SPRYKER_DOCKER_TAG}"
    local appImage="${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG}"
    local runtimeImage="${SPRYKER_DOCKER_PREFIX}_run_app:${SPRYKER_DOCKER_TAG}"

    Console::verbose "${INFO}Building base application image${NC}"

    docker build \
        -t "${baseAppImage}" \
        -f "${DEPLOYMENT_PATH}/images/common/base/Dockerfile" \
        --progress="${PROGRESS_TYPE}" \
        --build-arg "SPRYKER_PLATFORM_IMAGE=${SPRYKER_PLATFORM_IMAGE}" \
        --build-arg "SPRYKER_LOG_DIRECTORY=${SPRYKER_LOG_DIRECTORY}" \
        --build-arg "SPRYKER_PIPELINE=${SPRYKER_PIPELINE}" \
        --build-arg "APPLICATION_ENV=${APPLICATION_ENV}" \
        --build-arg "SPRYKER_DB_ENGINE=${SPRYKER_DB_ENGINE}" \
        --build-arg "KNOWN_HOSTS=${KNOWN_HOSTS}" \
        --build-arg "SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH:-"current"}" \
        --build-arg "SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP:-""}" \
        "${DEPLOYMENT_PATH}/context" 1>&2

    docker build \
        -t "${appImage}" \
        -t "${runtimeImage}" \
        -f "${DEPLOYMENT_PATH}/images/${folder}/app/Dockerfile" \
        --progress="${PROGRESS_TYPE}" \
        --build-arg "SPRYKER_PLATFORM_IMAGE=${baseAppImage}" \
        --build-arg "SPRYKER_DOCKER_PREFIX=${SPRYKER_DOCKER_PREFIX}" \
        --build-arg "SPRYKER_DOCKER_TAG=${SPRYKER_DOCKER_TAG}" \
        --build-arg "USER_UID=${USER_FULL_ID%%:*}" \
        --build-arg "COMPOSER_AUTH=${COMPOSER_AUTH}" \
        --build-arg "DEPLOYMENT_PATH=${DEPLOYMENT_PATH}" \
        --build-arg "SPRYKER_PIPELINE=${SPRYKER_PIPELINE}" \
        --build-arg "APPLICATION_ENV=${APPLICATION_ENV}" \
        --build-arg "SPRYKER_DB_ENGINE=${SPRYKER_DB_ENGINE}" \
        --build-arg "SPRYKER_COMPOSER_MODE=${SPRYKER_COMPOSER_MODE}" \
        --build-arg "SPRYKER_COMPOSER_AUTOLOAD=${SPRYKER_COMPOSER_AUTOLOAD}" \
        --build-arg "SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH:-"current"}" \
        --build-arg "SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP:-""}" \
        . 1>&2

    docker build \
        -t "${runtimeImage}" \
        -f "${DEPLOYMENT_PATH}/images/common/debug/Dockerfile" \
        --progress="${PROGRESS_TYPE}" \
        --build-arg "SPRYKER_APPLICATION_IMAGE=${appImage}" \
        "${DEPLOYMENT_PATH}/context/php" 1>&2
}

function Images::buildCli() {
    local folder=${1}
    local runtimeImage="${SPRYKER_DOCKER_PREFIX}_run_app:${SPRYKER_DOCKER_TAG}"

    Console::verbose "${INFO}Building CLI image${NC}"

    docker build -t "${SPRYKER_DOCKER_PREFIX}_cli:${SPRYKER_DOCKER_TAG}" \
        -f "${DEPLOYMENT_PATH}/images/${folder}/cli/Dockerfile" \
        --progress="${PROGRESS_TYPE}" \
        --build-arg "SPRYKER_APPLICATION_IMAGE=${runtimeImage}" \
        --build-arg "DEPLOYMENT_PATH=${DEPLOYMENT_PATH}" \
        --build-arg "COMPOSER_AUTH=${COMPOSER_AUTH}" \
        --build-arg "SPRYKER_PIPELINE=${SPRYKER_PIPELINE}" \
        --build-arg "SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH:-"current"}" \
        --build-arg "SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP:-""}" \
        .  1>&2
}

function Images::tagByApp() {
    local applicationName=$1
    local imageName=$2
    local baseImageName=${3:-${imageName}}
    local applicationPrefix=$(echo "$applicationName" | tr '[:upper:]' '[:lower:]')
    local tag="${imageName}-${applicationPrefix}"

    docker tag "${baseImageName}" "${tag}"
}

function Images::tagAll() {
    local tag=${1:-${SPRYKER_DOCKER_TAG}}

    for application in "${SPRYKER_APPLICATIONS[@]}"; do
        Images::tagByApp "${application}" "${SPRYKER_DOCKER_PREFIX}_app:${tag}" "${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG}"
        Images::tagByApp "${application}" "${SPRYKER_DOCKER_PREFIX}_run_app:${tag}" "${SPRYKER_DOCKER_PREFIX}_run_app:${SPRYKER_DOCKER_TAG}"
    done
}

function Images::printAll() {
    local tag=${1:-${SPRYKER_DOCKER_TAG}}

    for application in "${SPRYKER_APPLICATIONS[@]}"; do
        printf "%s %s_app:%s\n" "${application}" "${SPRYKER_DOCKER_PREFIX}" "${tag}"
    done

    printf "%s %s_frontend:%s\n" "frontend" "${SPRYKER_DOCKER_PREFIX}" "${tag}"
}
