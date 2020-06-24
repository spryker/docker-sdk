#!/bin/bash

function Assets::init() {
    # TODO investigate why do we need it. Probably we won't need it having frontend server assets inside
    if docker volume inspect "${SPRYKER_DOCKER_PREFIX}_assets" >/dev/null 2>&1; then
        return "${TRUE}"
    fi

    Console::verbose "${INFO}Creating docker volume '${SPRYKER_DOCKER_PREFIX}_assets'${NC}"
    docker volume create --name="${SPRYKER_DOCKER_PREFIX}_assets" >/dev/null
}

function Assets::destroy() {
    Console::verbose "${INFO}Removing assets volume${NC}"
    docker volume rm -f "${SPRYKER_DOCKER_PREFIX}_assets" || true
}

function Assets::export() {
    local tag=${1}
    local destinationPath=${2%/}

    local dockerAssetsTmpDirectory="/_tmp"
    local projectDockerAssetsTmpDirectory=${DEPLOYMENT_DIR}${dockerAssetsTmpDirectory}

    rm -rf "${projectDockerAssetsTmpDirectory}"
    mkdir -p "${projectDockerAssetsTmpDirectory}"

    echo -e "Preparing assets archives..." >/dev/stderr

    docker run --rm \
        -e PROJECT_DIR='/data' \
        --entrypoint='' \
        -v "${projectDockerAssetsTmpDirectory}:/data${dockerAssetsTmpDirectory}" \
        --name="${SPRYKER_DOCKER_PREFIX}_builder_assets" \
        "${SPRYKER_DOCKER_PREFIX}_builder_assets:${SPRYKER_DOCKER_TAG}" \
        bash -c "/tar-builder.sh ${tag} /data${dockerAssetsTmpDirectory}"

    echo -e "${INFO}File name:              Path:${NC}"

    for filePath in "${projectDockerAssetsTmpDirectory}"/*; do
        local fileName="$(basename -- "${filePath}")"

        rm -f "${destinationPath}/${fileName}"
        mv "${projectDockerAssetsTmpDirectory}/${fileName}" "${destinationPath}"

        echo -e "${OK}${fileName}${NC}          ${destinationPath}/${fileName}"
    done

    rm -rf "${projectDockerAssetsTmpDirectory}"
}

function Assets::areBuilt() {
    Console::start "Checking assets are built..."

    local assetsHostFolder=$(docker volume ls --filter "name=${SPRYKER_DOCKER_PREFIX}_assets" --format "{{ .Mountpoint }}")

    if [ -n "${assetsHostFolder}" ]; then
        local assetsFolderFilesCount=$(docker run -i --rm -v "${SPRYKER_DOCKER_PREFIX}_assets:/assets" "${SPRYKER_DOCKER_PREFIX}_cli:${SPRYKER_DOCKER_TAG}" ls /assets | wc -l | sed 's/^ *//')
        if [ "${assetsFolderFilesCount}" -gt 0 ]; then
            Console::verbose "[BUILT]"
            return "${TRUE}"
        fi
    fi

    return "${FALSE}"
}

function Assets::build() {

    local force=''
    if [ "$1" == '--force' ]; then
        force=1
        shift || true
    fi

    # TODO consider compiling assets always. Separating base image (composer install + everything else) would help.
    if [ -z "${force}" ] && Assets::areBuilt; then
        return "${TRUE}"
    fi

    local mode=${SPRYKER_ASSETS_MODE:-development}
    local volumeName=${SPRYKER_DOCKER_PREFIX}_assets
    local imageName=${SPRYKER_DOCKER_PREFIX}_builder_assets

    Console::verbose "${INFO}Generating assets in ${mode} mode...${NC}"

    docker build -t "${imageName}:${SPRYKER_DOCKER_TAG}" \
        -t "${SPRYKER_DOCKER_PREFIX}_frontend:${SPRYKER_DOCKER_TAG}" \
        --build-arg "SPRYKER_PLATFORM_IMAGE=${SPRYKER_PLATFORM_IMAGE}" \
        --build-arg "SPRYKER_DOCKER_PREFIX=${SPRYKER_DOCKER_PREFIX}" \
        --build-arg "SPRYKER_DOCKER_TAG=${SPRYKER_DOCKER_TAG}" \
        --build-arg "DEPLOYMENT_PATH=${DEPLOYMENT_PATH}" \
        --build-arg "SPRYKER_PLATFORM_IMAGE=${SPRYKER_PLATFORM_IMAGE}" \
        --build-arg "SPRYKER_FRONTEND_IMAGE=${SPRYKER_FRONTEND_IMAGE}" \
        --build-arg "SPRYKER_PIPELINE=${SPRYKER_PIPELINE}" \
        --build-arg "SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH:-"current"}" \
        --build-arg "SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP:-""}" \
        --build-arg SPRYKER_ASSETS_MODE="${mode}" \
        --progress="${PROGRESS_TYPE}" \
        -f "${DEPLOYMENT_PATH}/images/baked/frontend/Dockerfile" \
        .

    # TODO I assume this is unnecessary if assets are baked into image
    Console::verbose "${INFO}Creating docker volume '${SPRYKER_DOCKER_PREFIX}_assets'${NC}"
    docker volume create --name="${volumeName}" >/dev/null 2>&1

    local tty
    [ -t -0 ] && tty='t' || tty=''
    docker run -i${tty} --rm \
        -v "${volumeName}":/tmp/assets:nocopy \
        --name="${imageName}" \
        --entrypoint='' \
        "${imageName}:${SPRYKER_DOCKER_TAG}" \
        sh -c "rm -rf /tmp/assets/* && cp -r /data/public/* /tmp/assets"

    docker build -t "${imageName}:${SPRYKER_DOCKER_TAG}" \
        --build-arg SPRYKER_ASSETS_MODE="${mode}" \
        --build-arg "DEPLOYMENT_PATH=${DEPLOYMENT_PATH}" \
        --build-arg "FRONTEND_IMAGE_NAME=${SPRYKER_DOCKER_PREFIX}_frontend:${SPRYKER_DOCKER_TAG}" \
        --progress="${PROGRESS_TYPE}" \
        -f "${DEPLOYMENT_PATH}/images/baked/assets/Dockerfile" \
        .
}
