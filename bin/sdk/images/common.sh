#!/bin/bash

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

    local -a sshArgument=()
    local folder=${1}
    local withPushImages=${2:-${FALSE}}
    local baseAppImage="${SPRYKER_DOCKER_PREFIX}_base_app:${SPRYKER_DOCKER_TAG}"
    local appImage="${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG}"
    local localAppImage="${SPRYKER_DOCKER_PREFIX}_local_app:${SPRYKER_DOCKER_TAG}"
    local runtimeImage="${SPRYKER_DOCKER_PREFIX}_run_app:${SPRYKER_DOCKER_TAG}"
    local baseCliImage="${SPRYKER_DOCKER_PREFIX}_base_cli:${SPRYKER_DOCKER_TAG}"
    local cliImage="${SPRYKER_DOCKER_PREFIX}_cli:${SPRYKER_DOCKER_TAG}"
    local pipelineImage="${SPRYKER_DOCKER_PREFIX}_pipeline:${SPRYKER_DOCKER_TAG}"
    local runtimeCliImage="${SPRYKER_DOCKER_PREFIX}_run_cli:${SPRYKER_DOCKER_TAG}"

    if [ "${withPushImages}" == "${TRUE}" -a "${BUILDKIT_REGISTRY_CACHE_ENABLE}" == "true" ]; then
        local baseAppImageCache=('--cache-from' "type=registry,ref=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-cache:base-app-latest" '--cache-to' "mode=max,image-manifest=true,oci-mediatypes=true,type=registry,ref=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-cache:base-app-latest")
        local appImageCache=('--cache-from' "type=registry,ref=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-cache:app-latest" '--cache-to' "mode=max,image-manifest=true,oci-mediatypes=true,type=registry,ref=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-cache:app-latest")
        local localAppImageCache=('--cache-from' "type=registry,ref=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-cache:local-app-latest" '--cache-to' "mode=max,image-manifest=true,oci-mediatypes=true,type=registry,ref=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-cache:local-app-latest")
        local pipelineImageCache=('--cache-from' "type=registry,ref=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-cache:pipeline-latest" '--cache-to' "mode=max,image-manifest=true,oci-mediatypes=true,type=registry,ref=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-cache:pipeline-latest")
        local jenkinsImageCache=('--cache-from' "type=registry,ref=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-cache:jenkins-latest" '--cache-to' "mode=max,image-manifest=true,oci-mediatypes=true,type=registry,ref=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-cache:jenkins-latest")
        local loadFlag="--load"
    fi

    if [ -n "${SSH_AUTH_SOCK_IN_CLI}" ]; then
        sshArgument=('--ssh' 'default')
    fi

    Images::_prepareSecrets
    Registry::Trap::addExitHook 'removeBuildSecrets' "rm -f ${SECRETS_FILE_PATH}"

    Console::verbose "${INFO}Building Application images${NC}"

    echo "$(date): Building base image"
    docker build --output "type=oci,dest=base_app,tar=false" \
        -t "${baseAppImage}" \
        -f "${DEPLOYMENT_PATH}/images/common/application/Dockerfile" \
        "${baseAppImageCache[@]}" \
        --progress="${PROGRESS_TYPE}" \
        --build-arg "SPRYKER_PLATFORM_IMAGE=${SPRYKER_PLATFORM_IMAGE}" \
        --build-arg "SPRYKER_LOG_DIRECTORY=${SPRYKER_LOG_DIRECTORY}" \
        --build-arg "SPRYKER_PIPELINE=${SPRYKER_PIPELINE}" \
        --build-arg "APPLICATION_ENV=${APPLICATION_ENV}" \
        --build-arg "SPRYKER_DB_ENGINE=${SPRYKER_DB_ENGINE}" \
        --build-arg "KNOWN_HOSTS=${KNOWN_HOSTS}" \
        --build-arg "SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH:-"current"}" \
        --build-arg "SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP:-""}" \
        --build-arg "SPRYKER_NODE_IMAGE_VERSION=${SPRYKER_NODE_IMAGE_VERSION}" \
        --build-arg "SPRYKER_NODE_IMAGE_DISTRO=${SPRYKER_NODE_IMAGE_DISTRO}" \
        --build-arg "SPRYKER_NPM_VERSION=${SPRYKER_NPM_VERSION}" \
        "${DEPLOYMENT_PATH}/context" 1>&2

    echo "$(date): Building application image"
    for output_type in ${loadFlag} "--output type=oci,dest=app,tar=false"; do
        echo $output_type
        docker build  --build-context "${baseAppImage}=oci-layout://./base_app" \
            -t "${appImage}" \
            -f "${DEPLOYMENT_PATH}/images/${folder}/application/Dockerfile" \
            "${sshArgument[@]}" \
            $output_type \
            "${appImageCache[@]}" \
            --secret "id=secrets-env,src=$SECRETS_FILE_PATH" \
            --progress="${PROGRESS_TYPE}" \
            --build-arg "SPRYKER_PARENT_IMAGE=${baseAppImage}" \
            --build-arg "SPRYKER_DOCKER_PREFIX=${SPRYKER_DOCKER_PREFIX}" \
            --build-arg "SPRYKER_DOCKER_TAG=${SPRYKER_DOCKER_TAG}" \
            --build-arg "USER_UID=${USER_FULL_ID%%:*}" \
            --build-arg "DEPLOYMENT_PATH=${DEPLOYMENT_PATH}" \
            --build-arg "SPRYKER_PIPELINE=${SPRYKER_PIPELINE}" \
            --build-arg "APPLICATION_ENV=${APPLICATION_ENV}" \
            --build-arg "SPRYKER_DB_ENGINE=${SPRYKER_DB_ENGINE}" \
            --build-arg "SPRYKER_COMPOSER_MODE=${SPRYKER_COMPOSER_MODE}" \
            --build-arg "SPRYKER_COMPOSER_AUTOLOAD=${SPRYKER_COMPOSER_AUTOLOAD}" \
            --build-arg "SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH:-"current"}" \
            --build-arg "SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP:-""}" \
            . 1>&2
    done

    echo "$(date): Building local image"
    docker build --output "type=oci,dest=local_app,tar=false" --build-context "${appImage}=oci-layout://./app" \
        -t "${localAppImage}" \
        -t "${runtimeImage}" \
        -f "${DEPLOYMENT_PATH}/images/common/application-local/Dockerfile" \
        "${localAppImageCache[@]}" \
        --progress="${PROGRESS_TYPE}" \
        --build-arg "SPRYKER_PARENT_IMAGE=${appImage}" \
        "${DEPLOYMENT_PATH}/context" 1>&2

    if [ -n "${SPRYKER_XDEBUG_MODE_ENABLE}" ] && [ "${withPushImages}" == "${FALSE}" ]; then
        docker build \
            -t "${runtimeImage}" \
            -f "${DEPLOYMENT_PATH}/images/debug/application/Dockerfile" \
            --progress="${PROGRESS_TYPE}" \
            --build-arg "SPRYKER_PARENT_IMAGE=${localAppImage}" \
            "${DEPLOYMENT_PATH}/context" 1>&2
    fi

    Console::verbose "${INFO}Building CLI images${NC}"

    echo "$(date): Building pipeline image"
    docker build --build-context "${localAppImage}=oci-layout://./local_app" \
        -t "${baseCliImage}" \
        -t "${pipelineImage}" \
        -f "${DEPLOYMENT_PATH}/images/common/cli/Dockerfile" \
        "${pipelineImageCache[@]}" \
        ${loadFlag} \
        --progress="${PROGRESS_TYPE}" \
        --build-arg "SPRYKER_PARENT_IMAGE=${localAppImage}" \
        "${DEPLOYMENT_PATH}/context" 1>&2

    echo "$(date): Building runtimecli image"
    if [ "${withPushImages}" == "${FALSE}" ]; then
        docker build \
          -t "${cliImage}" \
          -t "${runtimeCliImage}" \
          -f "${DEPLOYMENT_PATH}/images/${folder}/cli/Dockerfile" \
          "${sshArgument[@]}" \
          --secret "id=secrets-env,src=$SECRETS_FILE_PATH" \
          --progress="${PROGRESS_TYPE}" \
          --build-arg "SPRYKER_PARENT_IMAGE=${baseCliImage}" \
          --build-arg "DEPLOYMENT_PATH=${DEPLOYMENT_PATH}" \
          --build-arg "SPRYKER_PIPELINE=${SPRYKER_PIPELINE}" \
          --build-arg "SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH:-"current"}" \
          --build-arg "SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP:-""}" \
          .  1>&2
    fi
    echo "$(date): finished building"

    if [ -n "${SPRYKER_XDEBUG_MODE_ENABLE}" ]; then
        docker build \
            -t "${runtimeCliImage}" \
            -f "${DEPLOYMENT_PATH}/images/debug/cli/Dockerfile" \
            --progress="${PROGRESS_TYPE}" \
            --build-arg "SPRYKER_PARENT_IMAGE=${cliImage}" \
            "${DEPLOYMENT_PATH}/context" 1>&2
    fi

    if [ "${withPushImages}" == "${TRUE}" ]; then
        local jenkinsImage="${SPRYKER_DOCKER_PREFIX}_jenkins:${SPRYKER_DOCKER_TAG}"

        docker build --build-context "${appImage}=oci-layout://./app" \
            -t "${jenkinsImage}" \
            -f "${DEPLOYMENT_PATH}/images/common/services/jenkins/export/Dockerfile" \
            "${jenkinsImageCache[@]}" \
            ${loadFlag} \
            --progress="${PROGRESS_TYPE}" \
            --build-arg "SPRYKER_PARENT_IMAGE=${appImage}" \
            "${DEPLOYMENT_PATH}/" 1>&2
    fi

    Registry::Trap::releaseExitHook 'removeBuildSecrets'
}

function Images::_buildFrontend() {
    local folder=${1}
    local cliImage="${SPRYKER_DOCKER_PREFIX}_cli:${SPRYKER_DOCKER_TAG}"
    local builderAssetsImage="$(Assets::getImageTag)"
    local baseFrontendImage="${SPRYKER_DOCKER_PREFIX}_base_frontend:${SPRYKER_DOCKER_TAG}"
    local frontendImage="${SPRYKER_DOCKER_PREFIX}_frontend:${SPRYKER_DOCKER_TAG}"
    local runtimeFrontendImage="${SPRYKER_DOCKER_PREFIX}_run_frontend:${SPRYKER_DOCKER_TAG}"

    Console::verbose "${INFO}Building Frontend images${NC}"

    docker build \
        -t "${baseFrontendImage}" \
        -f "${DEPLOYMENT_PATH}/images/common/frontend/Dockerfile" \
        --progress="${PROGRESS_TYPE}" \
        --build-arg "SPRYKER_FRONTEND_IMAGE=${SPRYKER_FRONTEND_IMAGE}" \
        --build-arg "SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH:-"current"}" \
        --build-arg "SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP:-""}" \
        --build-arg "SPRYKER_MAINTENANCE_MODE_ENABLED=${SPRYKER_MAINTENANCE_MODE_ENABLED}" \
        "${DEPLOYMENT_PATH}/context" 1>&2

    docker build \
        -t "${frontendImage}" \
        -t "${runtimeFrontendImage}" \
        -f "${DEPLOYMENT_PATH}/images/${folder}/frontend/Dockerfile" \
        --progress="${PROGRESS_TYPE}" \
        --build-arg "SPRYKER_PARENT_IMAGE=${baseFrontendImage}" \
        --build-arg "SPRYKER_ASSETS_BUILDER_IMAGE=${builderAssetsImage}" \
        --build-arg "SPRYKER_MAINTENANCE_MODE_ENABLED=${SPRYKER_MAINTENANCE_MODE_ENABLED}" \
        "${DEPLOYMENT_PATH}/context" 1>&2

    if [ -n "${SPRYKER_XDEBUG_MODE_ENABLE}" ] && [ "${withPushImages}" == "${FALSE}" ]; then
        echo "SPRYKER_XDEBUG_MODE_ENABLE enabled"
        docker build \
            -t "${runtimeFrontendImage}" \
            -f "${DEPLOYMENT_PATH}/images/debug/frontend/Dockerfile" \
            --progress="${PROGRESS_TYPE}" \
            --build-arg "SPRYKER_PARENT_IMAGE=${frontendImage}" \
            --build-arg "SPRYKER_XDEBUG_MODE_ENABLE=${SPRYKER_XDEBUG_MODE_ENABLE}" \
            "${DEPLOYMENT_PATH}/context" 1>&2
    fi
}

function Images::_buildGateway() {
    local gatewayImage="${SPRYKER_DOCKER_PREFIX}_gateway:${SPRYKER_DOCKER_TAG}"

    Console::verbose "${INFO}Building Gateway image${NC}"

    docker build \
        -t "${gatewayImage}" \
        -f "${DEPLOYMENT_PATH}/images/common/gateway/Dockerfile" \
        --progress="${PROGRESS_TYPE}" \
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
