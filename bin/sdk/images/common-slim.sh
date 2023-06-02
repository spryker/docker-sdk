#!/bin/bash
set -eo

require docker

function Images::pull() {
    docker pull "${SPRYKER_PLATFORM_IMAGE}" || true
}

function Images::destroy() {
    Console::verbose "Removing all Spryker images"

    # ${XARGS_NO_RUN_IF_EMPTY} must be without quotes
    # shellcheck disable=SC2086
    docker images --filter "reference=${SPRYKER_DOCKER_PREFIX}_*:${SPRYKER_DOCKER_TAG}" --format "{{.ID}}" | xargs ${XARGS_NO_RUN_IF_EMPTY} docker rmi -f
    docker images --filter "reference=${SPRYKER_DOCKER_PREFIX}_builder_assets*" --format "{{.ID}}" | xargs ${XARGS_NO_RUN_IF_EMPTY} docker rmi -f
    docker images --filter "reference=spryker_docker_sdk*" --format "{{.ID}}" | xargs ${XARGS_NO_RUN_IF_EMPTY} docker rmi -f

    docker rmi -f "${SPRYKER_DOCKER_PREFIX}_cli" || true
    docker rmi -f "${SPRYKER_DOCKER_PREFIX}_app" || true
    docker rmi -f "${SPRYKER_PLATFORM_IMAGE}" || true
}

# Using temporary file for secrets as `docker secret` is only available for swarm mode.
function Images::_prepareSecrets() {
    env - "${SECRETS_ENVIRONMENT[@]}" env > "${SECRETS_FILE_PATH}"
}

function Images::_buildApp() {

    local appImage="${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG}"
    local appBuildImage="${SPRYKER_DOCKER_PREFIX}_app_build:${SPRYKER_DOCKER_TAG}"
    local pipelineImage="${SPRYKER_DOCKER_PREFIX}_pipeline:${SPRYKER_DOCKER_TAG}"
    local jenkinsImage="${SPRYKER_DOCKER_PREFIX}_jenkins:${SPRYKER_DOCKER_TAG}"

    Images::_prepareSecrets
    Registry::Trap::addExitHook 'removeBuildSecrets' "rm -f ${SECRETS_FILE_PATH}"

    Console::verbose "$(date) ${INFO}Building application-build ${NC}"

    docker build \
        -t "${appBuildImage}" \
        -f "${DEPLOYMENT_PATH}/images/baked/slim/application/Dockerfile" \
        --progress="${PROGRESS_TYPE}" \
        --target "application-build" \
        --build-arg "SPRYKER_PLATFORM_IMAGE=${SPRYKER_PLATFORM_IMAGE}" \
        --build-arg "SPRYKER_NPM_VERSION=${SPRYKER_NPM_VERSION}" \
        --build-arg "SPRYKER_COMPOSER_MODE=${SPRYKER_COMPOSER_MODE}" \
        --build-arg "SPRYKER_PIPELINE=${SPRYKER_PIPELINE}" \
        --build-arg "APPLICATION_ENV=${APPLICATION_ENV}" \
        --build-arg "SPRYKER_DB_ENGINE=${SPRYKER_DB_ENGINE}" \
        --build-arg "SPRYKER_COMPOSER_AUTOLOAD=${SPRYKER_COMPOSER_AUTOLOAD}" \
        --secret "id=secrets-env,src=$SECRETS_FILE_PATH" \
        . 1>&2

    Console::verbose "$(date) ${INFO}Building docker-sdk-context-build ${NC}"

    # have to build separately due to different path
    docker build \
        -t "docker-sdk-context-build" \
        -f "${DEPLOYMENT_PATH}/images/baked/slim/docker-sdk-context-build/Dockerfile" \
        --progress="${PROGRESS_TYPE}" \
        --build-arg "SPRYKER_PARENT_IMAGE=${appBuildImage}" \
        --target "docker-sdk-context-build" \
        "${DEPLOYMENT_PATH}/context" 1>&2

    Console::verbose "$(date) ${INFO}Building app ${NC}"
    docker build \
        -t "${appImage}" \
        -f "${DEPLOYMENT_PATH}/images/baked/slim/application/Dockerfile" \
        --progress="${PROGRESS_TYPE}" \
        --build-arg "SPRYKER_LOG_DIRECTORY=${SPRYKER_LOG_DIRECTORY}" \
        --build-arg "KNOWN_HOSTS=${KNOWN_HOSTS}" \
        --build-arg "SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH:-"current"}" \
        --build-arg "SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP:-""}" \
        --build-arg "SPRYKER_PIPELINE=${SPRYKER_PIPELINE}" \
        --build-arg "APPLICATION_ENV=${APPLICATION_ENV}" \
        --build-arg "SPRYKER_DB_ENGINE=${SPRYKER_DB_ENGINE}" \
        --build-arg "DEPLOYMENT_PATH=${DEPLOYMENT_PATH}" \
        . 1>&2

    Console::verbose "$(date) ${INFO}Building pipeline (cli)${NC}"

    docker build \
        -t "${pipelineImage}" \
        -f "${DEPLOYMENT_PATH}/images/baked/slim/cli/Dockerfile" \
        --progress="${PROGRESS_TYPE}" \
        --build-arg "SPRYKER_PARENT_IMAGE=${appImage}" \
        "${DEPLOYMENT_PATH}/context" 1>&2

    Console::verbose "$(date) ${INFO}Building Jenkins${NC}"
    docker build \
        -t "${jenkinsImage}" \
        -f "${DEPLOYMENT_PATH}/images/baked/slim/jenkins/Dockerfile" \
        --progress="${PROGRESS_TYPE}" \
        --build-arg "SPRYKER_PARENT_IMAGE=${appImage}" \
        "${DEPLOYMENT_PATH}/" 1>&2

    Registry::Trap::releaseExitHook 'removeBuildSecrets'
}

function Images::_buildAssets() {
    local assetsBuildImage="${SPRYKER_DOCKER_PREFIX}_assets_build:${SPRYKER_DOCKER_TAG}"
    local appImage="${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG}"

    Console::verbose "$(date) ${INFO}Building assets${NC}"
    docker build \
        -t "${assetsBuildImage}" \
        -f "${DEPLOYMENT_PATH}/images/baked/slim/assets/Dockerfile" \
        --progress="${PROGRESS_TYPE}" \
        --build-arg "SPRYKER_PARENT_IMAGE=${appImage}" \
        --build-arg "SPRYKER_PIPELINE=${SPRYKER_PIPELINE}" \
        --build-arg "SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH:-"current"}" \
        . 1>&2
}

function Images::_buildFrontend() {
    local cliImage="${SPRYKER_DOCKER_PREFIX}_cli:${SPRYKER_DOCKER_TAG}"
    local builderAssetsImage="$(Assets::getImageTag)"
    local baseFrontendImage="${SPRYKER_DOCKER_PREFIX}_base_frontend:${SPRYKER_DOCKER_TAG}"
    local frontendImage="${SPRYKER_DOCKER_PREFIX}_frontend:${SPRYKER_DOCKER_TAG}"
    local runtimeFrontendImage="${SPRYKER_DOCKER_PREFIX}_run_frontend:${SPRYKER_DOCKER_TAG}"

    Console::verbose "$(date) ${INFO}Building base_frontend${NC}"

    docker build \
        -t "${baseFrontendImage}" \
        -f "${DEPLOYMENT_PATH}/images/common/frontend/Dockerfile" \
        --progress="${PROGRESS_TYPE}" \
        --build-arg "SPRYKER_FRONTEND_IMAGE=${SPRYKER_FRONTEND_IMAGE}" \
        --build-arg "SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH:-"current"}" \
        --build-arg "SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP:-""}" \
        --build-arg "SPRYKER_MAINTENANCE_MODE_ENABLED=${SPRYKER_MAINTENANCE_MODE_ENABLED}" \
        "${DEPLOYMENT_PATH}/context" 1>&2

    Console::verbose "$(date) ${INFO}Building frontend${NC}"
    docker build \
        -t "${frontendImage}" \
        -t "${runtimeFrontendImage}" \
        -f "${DEPLOYMENT_PATH}/images/${folder}/frontend/Dockerfile" \
        --progress="${PROGRESS_TYPE}" \
        --build-arg "SPRYKER_PARENT_IMAGE=${baseFrontendImage}" \
        --build-arg "SPRYKER_ASSETS_BUILDER_IMAGE=${builderAssetsImage}" \
        --build-arg "SPRYKER_MAINTENANCE_MODE_ENABLED=${SPRYKER_MAINTENANCE_MODE_ENABLED}" \
        "${DEPLOYMENT_PATH}/context" 1>&2

    Console::verbose "$(date) ${INFO}Building runtime frontend${NC}"
    if [ -n "${SPRYKER_XDEBUG_MODE_ENABLE}" ]; then
        docker build \
            -t "${runtimeFrontendImage}" \
            -f "${DEPLOYMENT_PATH}/images/debug/frontend/Dockerfile" \
            --progress="${PROGRESS_TYPE}" \
            --build-arg "SPRYKER_PARENT_IMAGE=${frontendImage}" \
            --build-arg "SPRYKER_XDEBUG_MODE_ENABLE=${SPRYKER_XDEBUG_MODE_ENABLE}" \
            "${DEPLOYMENT_PATH}/context" 1>&2
    fi
}

function Images::_tagByApp() {
    local applicationName=$1
    local imageName=$2
    local baseImageName=${3:-${imageName}}
    local applicationPrefix="$(echo "$applicationName" | tr '[:upper:]' '[:lower:]')"
    local tag="${imageName}-${applicationPrefix}"

    docker tag "${baseImageName}" "${tag}"
}

function Images::tagApplications() {
    local tag=${1:-${SPRYKER_DOCKER_TAG}}

    for application in "${SPRYKER_APPLICATIONS[@]}"; do
        Images::_tagByApp "${application}" "${SPRYKER_DOCKER_PREFIX}_app:${tag}" "${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG}"
        Images::_tagByApp "${application}" "${SPRYKER_DOCKER_PREFIX}_run_app:${tag}" "${SPRYKER_DOCKER_PREFIX}_run_app:${SPRYKER_DOCKER_TAG}"
    done

    Images::_tagByApp pipeline "${SPRYKER_DOCKER_PREFIX}_pipeline:${tag}" "${SPRYKER_DOCKER_PREFIX}_pipeline:${SPRYKER_DOCKER_TAG}"
}

function Images::tagFrontend() {
    local tag=${1:-${SPRYKER_DOCKER_TAG}}

    Images::_tagByApp frontend "${SPRYKER_DOCKER_PREFIX}_frontend:${tag}" "${SPRYKER_DOCKER_PREFIX}_frontend:${SPRYKER_DOCKER_TAG}"
}

function Images::printAll() {
    local tag=${1:-${SPRYKER_DOCKER_TAG}}

    for application in "${SPRYKER_APPLICATIONS[@]}"; do
        local applicationPrefix=$(echo "${application}" | tr '[:upper:]' '[:lower:]')
        printf "%s %s_app:%s\n" "${application}" "${SPRYKER_DOCKER_PREFIX}" "${tag}-${applicationPrefix}"
    done

    printf "%s %s_frontend:%s\n" "frontend" "${SPRYKER_DOCKER_PREFIX}" "${tag}-frontend"
    printf "%s %s_pipeline:%s\n" "pipeline" "${SPRYKER_DOCKER_PREFIX}" "${tag}-pipeline"
}
