#!/bin/bash

set -e

pushd "${BASH_SOURCE%/*}" > /dev/null
. ../constants.sh
. ../console.sh
popd > /dev/null

function exportAssets()
{
    local tag=${1:-${SPRYKER_DOCKER_TAG}}
    local destinationPath=${2:-${PROJECT_DIR}}

    local dockerAssetsTmpDirectory=/docker/bin/assets/_tmp/
    local projectDockerAssetsTmpDirectory=${PROJECT_DIR}${dockerAssetsTmpDirectory}

    destinationPath=${destinationPath%/}

    mkdir -p "${projectDockerAssetsTmpDirectory}"

    docker run --rm \
        -e PROJECT_DIR='/data' \
        -v "${SPRYKER_DOCKER_PREFIX}_assets":/assets \
        -v "${PROJECT_DIR}/docker":/data/docker \
        --name="${SPRYKER_DOCKER_PREFIX}_builder_assets" \
        "${SPRYKER_DOCKER_PREFIX}_builder_assets:${SPRYKER_DOCKER_TAG}" \
        bash -c "./docker/bin/assets/tar-builder.sh ${tag} /data/${dockerAssetsTmpDirectory}"

    echo -e "${INFO}File name:\t\t\t\tPath:${NC}"

    for filePath in "${projectDockerAssetsTmpDirectory}"*;
    do
        local fileName="$(basename -- ${filePath})"

        mv "${filePath}" "${destinationPath}"

        echo -e "${OK}${fileName}${NC}\t\t\t\t${destinationPath}/${fileName}"
    done

    rm -rf "${projectDockerAssetsTmpDirectory}"
}

function areAssetsBuilt()
{
    verbose -n "Checking assets are built..."

    local assetsHostFolder=$(docker volume ls --filter "name=${SPRYKER_DOCKER_PREFIX}_assets" --format "{{ .Mountpoint }}")

    if [ ! -z "${assetsHostFolder}" ];
    then
      local assetsFolderFilesCount=$(docker run -i --rm -v ${SPRYKER_DOCKER_PREFIX}_assets:/assets ${SPRYKER_DOCKER_PREFIX}_cli:${SPRYKER_DOCKER_TAG} ls /assets|wc -l | sed 's/^ *//')
      [ ${assetsFolderFilesCount} -gt 0 ] && verbose "[BUILT]" && return ${__TRUE}
    fi

    verbose ""
    return ${__FALSE}
}

function buildAssets()
{
    if [ "$1" = ${IF_NOT_PERFORMED} ] && areAssetsBuilt;
    then
        return ${__TRUE}
    fi

    local volumeName=${SPRYKER_DOCKER_PREFIX}_assets
    local imageName=${SPRYKER_DOCKER_PREFIX}_builder_assets

    verbose "${INFO}Creating docker volume '${SPRYKER_DOCKER_PREFIX}_assets'${NC}"
    docker volume rm "${volumeName}" > /dev/null || true
    docker volume create --name="${volumeName}"

    verbose "${INFO}Generating assets${NC}"

    docker image tag "${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG}" spryker_app:latest

    docker build -t "${imageName}:${SPRYKER_DOCKER_TAG}" \
        --build-arg SPRYKER_DOCKER_PREFIX="${SPRYKER_DOCKER_PREFIX}" \
        --build-arg SPRYKER_DOCKER_TAG="${SPRYKER_DOCKER_TAG}" \
        --build-arg DEPLOYMENT_PATH="${DEPLOYMENT_PATH}" \
        --progress="${PROGRESS_TYPE}" \
        -f "${DEPLOYMENT_PATH}/images/builder_assets/Dockerfile" \
        .

    local tty
    [ -t -0 ] && tty='t' || tty=''
    docker run -i${tty} --rm \
        -v "${volumeName}":/assets \
        --name="${imageName}" \
        "${imageName}:${SPRYKER_DOCKER_TAG}" \
        true

    docker rmi spryker_app:latest
}

export -f buildAssets
export -f exportAssets
