#!/bin/bash

function Assets::export() {
    # deprecated
    local tag=${1}
    local destinationPath=${2%/}

    local builderAssetsImage=$(Assets::getImageTag)
    local dockerAssetsTmpDirectory="/_tmp"
    local projectDockerAssetsTmpDirectory=${DEPLOYMENT_DIR}${dockerAssetsTmpDirectory}

    rm -rf "${projectDockerAssetsTmpDirectory}"
    mkdir -p "${projectDockerAssetsTmpDirectory}"

    local command="true"
    for entrypoint in "${SPRYKER_ENTRYPOINTS[@]}"; do
        command="${command} && \$([ -d '/data/public/${entrypoint}/assets' ] && tar czf '/data${dockerAssetsTmpDirectory}/assets-${entrypoint}-${tag}.tar' -C '/data/public/${entrypoint}/assets' . || true)"
    done

    Console::start "Preparing assets archives..."

    # To support root user
    local userToRun=("-u" "${USER_FULL_ID}")
    if [ "${USER_FULL_ID%%:*}" != '0' ]; then
        userToRun=()
    fi
    docker run -i --rm "${userToRun[@]}" \
        -e PROJECT_DIR='/data' \
        -v "${DEPLOYMENT_DIR}/bin:/data/standalone" \
        -v "${projectDockerAssetsTmpDirectory}:/data${dockerAssetsTmpDirectory}" \
        --entrypoint='' \
        --name="${SPRYKER_DOCKER_PREFIX}_builder_assets" \
        "${builderAssetsImage}" \
        sh -c "${command}" 2>&1

    Console::log "The following assets archives have been prepared:"

    for entrypoint in "${SPRYKER_ENTRYPOINTS[@]}"; do
        local fileName="assets-${entrypoint}-${tag}.tar"
        if [ ! -f "${projectDockerAssetsTmpDirectory}/${fileName}" ]; then
            continue
        fi

        rm -f "${destinationPath}/${fileName}"
        mv "${projectDockerAssetsTmpDirectory}/${fileName}" "${destinationPath}"

        echo "${entrypoint} ${destinationPath}/${fileName}"
    done

    rm -rf "${projectDockerAssetsTmpDirectory}"
}

function Assets::getImageTag() {
    echo -n "${SPRYKER_DOCKER_PREFIX}_builder_assets:${SPRYKER_DOCKER_TAG}-${SPRYKER_REPOSITORY_HASH}"
}

function Assets::areBuilt() {
    Console::start "Checking assets are built..."

    local builderAssetsImage=$(Assets::getImageTag)

    if docker image inspect "${builderAssetsImage}" >/dev/null 2>&1; then
        Console::end "[BUILT]"
        return "${TRUE}"
    fi

    return "${FALSE}"
}

function Assets::build() {

    local force=''
    if [ "$1" == '--force' ]; then
        force=1
        shift || true
    fi

    if [ -z "${force}" ] && Assets::areBuilt; then
        return "${TRUE}"
    fi

    Console::start "Cleaning old assets..."

    # ${XARGS_NO_RUN_IF_EMPTY} must be without quotes
    # shellcheck disable=SC2086
    docker images --filter "reference=${SPRYKER_DOCKER_PREFIX}_builder_assets:${SPRYKER_DOCKER_TAG}*" --format "{{.ID}}" | xargs ${XARGS_NO_RUN_IF_EMPTY} docker rmi -f

    Console::end "[DONE]"
    Console::start "Building assets..."

    local builderAssetsImage=$(Assets::getImageTag)
    local cliImage="${SPRYKER_DOCKER_PREFIX}_cli:${SPRYKER_DOCKER_TAG}"
    local mode=${SPRYKER_ASSETS_MODE:-development}

    docker build \
        -t "${builderAssetsImage}" \
        -f "${DEPLOYMENT_PATH}/images/baked/assets/Dockerfile" \
        --progress="${PROGRESS_TYPE}" \
        --build-arg "SPRYKER_PARENT_IMAGE=${cliImage}" \
        --build-arg "SPRYKER_ASSETS_MODE=${mode}" \
        --build-arg "SPRYKER_PIPELINE=${SPRYKER_PIPELINE}" \
        --build-arg "SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH:-"current"}" \
        --build-arg "SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP:-""}" \
        --build-arg "SPRYKER_NPM_TOKEN=${SPRYKER_NPM_TOKEN:-""}" \
        . 1>&2

    Console::end "[DONE]"
}
