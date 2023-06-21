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
    local composerCacheImage="${SPRYKER_DOCKER_PREFIX}_composer_cache:${SPRYKER_DOCKER_TAG}"
    local pipelineImage="${SPRYKER_DOCKER_PREFIX}_pipeline:${SPRYKER_DOCKER_TAG}"
    local jenkinsImage="${SPRYKER_DOCKER_PREFIX}_jenkins:${SPRYKER_DOCKER_TAG}"
    local dockerSdkContextBuildImage="${SPRYKER_DOCKER_PREFIX}_docker_sdk_context_build:${SPRYKER_DOCKER_TAG}"

    Images::_prepareSecrets
    Registry::Trap::addExitHook 'removeBuildSecrets' "rm -f ${SECRETS_FILE_PATH}"

    Console::verbose "$(date) ${INFO}Importing composer cache ${NC}"
    # it's expected to fail first time, since cache image doesn't yet exist in ECR
    docker build \
        -f "${DEPLOYMENT_PATH}/images/baked/slim/composer-cache-import/Dockerfile" \
        --build-arg "COMPOSER_CACHE_IMAGE=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-cache:composer-cache-latest" \
        . 1>&2 | true

    Console::verbose "$(date) ${INFO}Building application-build ${NC}"
    docker build \
        -t "${appBuildImage}" \
        -f "${DEPLOYMENT_PATH}/images/baked/slim/application-build/Dockerfile" \
        --build-arg "SPRYKER_PLATFORM_IMAGE=${SPRYKER_PLATFORM_IMAGE}" \
        --build-arg "SPRYKER_COMPOSER_MODE=${SPRYKER_COMPOSER_MODE}" \
        --build-arg "SPRYKER_PIPELINE=${SPRYKER_PIPELINE}" \
        --build-arg "APPLICATION_ENV=${APPLICATION_ENV}" \
        --build-arg "SPRYKER_DB_ENGINE=${SPRYKER_DB_ENGINE}" \
        --build-arg "SPRYKER_COMPOSER_AUTOLOAD=${SPRYKER_COMPOSER_AUTOLOAD}" \
        --build-arg "SPRYKER_DOCKER_SDK_CONTEXT_BUILD_IMAGE=${dockerSdkContextBuildImage}" \
        --secret "id=secrets-env,src=$SECRETS_FILE_PATH" \
        . 1>&2

    Console::verbose "$(date) ${INFO}Exporting composer cache ${NC}"
    docker build \
        -t "${composerCacheImage}" \
        -f "${DEPLOYMENT_PATH}/images/baked/slim/composer-cache-export/Dockerfile" \
        . 1>&2

    Console::verbose "$(date) ${INFO}Building docker-sdk-context-build ${NC}"

    # have to build separately due to different path.
    docker build \
        -t "${dockerSdkContextBuildImage}" \
        -f "${DEPLOYMENT_PATH}/images/baked/slim/docker-sdk-context-build/Dockerfile" \
        --build-arg "SPRYKER_PARENT_IMAGE=${appBuildImage}" \
        "${DEPLOYMENT_PATH}/context" 1>&2

    Console::verbose "$(date) ${INFO}Building app ${NC}"
    local application="$(echo "${SPRYKER_APPLICATIONS[0]}" | tr '[:upper:]' '[:lower:]')"
    docker build \
        -t "${appImage}" \
        -f "${DEPLOYMENT_PATH}/images/baked/slim/application/Dockerfile" \
        --build-arg "SPRYKER_LOG_DIRECTORY=${SPRYKER_LOG_DIRECTORY}" \
        --build-arg "KNOWN_HOSTS=${KNOWN_HOSTS}" \
        --build-arg "SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH:-"current"}" \
        --build-arg "SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP:-""}" \
        --build-arg "SPRYKER_PIPELINE=${SPRYKER_PIPELINE}" \
        --build-arg "APPLICATION_ENV=${APPLICATION_ENV}" \
        --build-arg "SPRYKER_DB_ENGINE=${SPRYKER_DB_ENGINE}" \
        --build-arg "SPRYKER_DOCKER_SDK_CONTEXT_BUILD_IMAGE=${dockerSdkContextBuildImage}" \
        --build-arg "SPRYKER_APP_BUILD_IMAGE=${appBuildImage}" \
        . 1>&2

#        -t "${AWS_ACCOUNT_ID}".dkr.ecr."${AWS_REGION}".amazonaws.com/"${SPRYKER_PROJECT_NAME}"-"${application}":latest \
#        --build-arg BUILDKIT_INLINE_CACHE=1 \
#        --cache-from type=registry,ref="${AWS_ACCOUNT_ID}".dkr.ecr."${AWS_REGION}".amazonaws.com/"${SPRYKER_PROJECT_NAME}"-"${application}":latest \

    Console::verbose "$(date) ${INFO}Building pipeline (cli)${NC}"

    docker build \
        -t "${pipelineImage}" \
        -f "${DEPLOYMENT_PATH}/images/baked/slim/cli/Dockerfile" \
        --build-arg "SPRYKER_PARENT_IMAGE=${appImage}" \
        "${DEPLOYMENT_PATH}/context" 1>&2

    Console::verbose "$(date) ${INFO}Building Jenkins${NC}"
    docker build \
        -t "${jenkinsImage}" \
        -f "${DEPLOYMENT_PATH}/images/baked/slim/jenkins/Dockerfile" \
        --build-arg "SPRYKER_PARENT_IMAGE=${appImage}" \
        "${DEPLOYMENT_PATH}/" 1>&2

    Registry::Trap::releaseExitHook 'removeBuildSecrets'
}

Images::_importNodeCache() {
    Console::verbose "$(date) ${INFO}Importing node cache ${NC}"
    # it's expected to fail first time, since cache image doesn't yet exist in ECR
    docker build \
        -f "${DEPLOYMENT_PATH}/images/baked/slim/node-cache-import/Dockerfile" \
        --build-arg "NODE_CACHE_IMAGE=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-cache:node-cache-latest" \
        . 1>&2 | true
}

function Images::_buildAssets() {
    local assetsBuildImage="${SPRYKER_DOCKER_PREFIX}_assets_build:${SPRYKER_DOCKER_TAG}"
    local appImage="${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG}"
    local nodeCacheImage="${SPRYKER_DOCKER_PREFIX}_node_cache:${SPRYKER_DOCKER_TAG}"

    Console::verbose "$(date) ${INFO}Building assets${NC}"
    docker build \
        -t "${assetsBuildImage}" \
        -f "${DEPLOYMENT_PATH}/images/baked/slim/assets/Dockerfile" \
        --build-arg "SPRYKER_PARENT_IMAGE=${appImage}" \
        --build-arg "SPRYKER_PIPELINE=${SPRYKER_PIPELINE}" \
        --build-arg "SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH:-"current"}" \
        --build-arg "SPRYKER_NPM_VERSION=${SPRYKER_NPM_VERSION}" \
        --build-arg "SPRYKER_NODE_IMAGE_VERSION=${SPRYKER_NODE_IMAGE_VERSION}" \
        --build-arg "SPRYKER_NODE_IMAGE_DISTRO=${SPRYKER_NODE_IMAGE_DISTRO}" \
        . 1>&2

    Console::verbose "$(date) ${INFO}Exporting node cache ${NC}"
    docker buildx create --name zstd-builder \
        --driver docker-container \
        --driver-opt image=moby/buildkit:v0.11.6
    docker buildx use zstd-builder

    docker build \
        -t "${nodeCacheImage}" \
        -f "${DEPLOYMENT_PATH}/images/baked/slim/node-cache-export/Dockerfile" \
        --progress="${PROGRESS_TYPE}" \
        . 1>&2

    docker buildx ls
    docker buildx create --driver-opt image=moby/buildkit:master --use
    docker build \
        -f "${DEPLOYMENT_PATH}/images/baked/slim/node-cache-export-zstd/Dockerfile" \
        --build-context node_cache="${nodeCacheImage}" \
        --output "type=image,name=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-cache:node-cache-latest,oci-mediatypes=true,compression=zstd,compression-level=3,force-compression=true,push=true" \
        --progress="${PROGRESS_TYPE}" \
        . 1>&2
}

function Images::_buildFrontend() {
    local assetsBuildImage="${SPRYKER_DOCKER_PREFIX}_assets_build:${SPRYKER_DOCKER_TAG}"
    local frontendImage="${SPRYKER_DOCKER_PREFIX}_frontend:${SPRYKER_DOCKER_TAG}"

    Console::verbose "$(date) ${INFO}Building frontend${NC}"

    docker build \
        -t "${frontendImage}" \
        -f "${DEPLOYMENT_PATH}/images/baked/slim/frontend/Dockerfile" \
        --build-arg "SPRYKER_FRONTEND_IMAGE=${SPRYKER_FRONTEND_IMAGE}" \
        --build-arg "SPRYKER_MAINTENANCE_MODE_ENABLED=${SPRYKER_MAINTENANCE_MODE_ENABLED}" \
        --build-arg "SPRYKER_PARENT_IMAGE=${assetsBuildImage}" \
        --build-arg "SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH:-"current"}" \
        --build-arg "SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP:-""}" \
        "${DEPLOYMENT_PATH}/context" 1>&2
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
