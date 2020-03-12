#!/bin/bash

set -e

pushd "${BASH_SOURCE%/*}" > /dev/null
. ../constants.sh
. ../console.sh
popd > /dev/null

function exportAssets()
{
    local tag=${1}
    local destinationPath=${2%/}

    local dockerAssetsTmpDirectory="/_tmp"
    local projectDockerAssetsTmpDirectory=${DEPLOYMENT_DIR}${dockerAssetsTmpDirectory}

    rm -rf "${projectDockerAssetsTmpDirectory}"
    mkdir -p "${projectDockerAssetsTmpDirectory}"

    local command="true"

    for application in "${SPRYKER_APPLICATIONS[@]}";
    do
        command="${command} && \$([ -d '/assets/${application}' ] && tar czf '/data${dockerAssetsTmpDirectory}/assets-${application}-${tag}.tar' -C '/assets/${application}' . || true)"
    done

    echo -e "Preparing assets archives..." > /dev/stderr

    docker run --rm \
        -e PROJECT_DIR='/data' \
        -v "${DEPLOYMENT_DIR}/bin:/data/standalone" \
        -v "${projectDockerAssetsTmpDirectory}:/data${dockerAssetsTmpDirectory}" \
        --name="${SPRYKER_DOCKER_PREFIX}_builder_assets" \
        "${SPRYKER_DOCKER_PREFIX}_builder_assets:${SPRYKER_DOCKER_TAG}" \
        sh -c "${command}" 2>&1

    echo -e "${INFO}The following assets archives have been prepared${NC}:" > /dev/stderr

    for application in "${SPRYKER_APPLICATIONS[@]}";
    do
        local fileName="assets-${application}-${tag}.tar"
        if [ ! -f "${projectDockerAssetsTmpDirectory}/${fileName}" ]; then
            continue
        fi

        rm -f "${destinationPath}/${fileName}"
        mv "${projectDockerAssetsTmpDirectory}/${fileName}" "${destinationPath}"

        echo "${application} ${destinationPath}/${fileName}"
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
        # TODO consider compiling assets always. Separating base image (composer install + everything else) would help.
        return ${__TRUE}
    fi

    local volumeName=${SPRYKER_DOCKER_PREFIX}_assets
    local imageName=${SPRYKER_DOCKER_PREFIX}_builder_assets

    verbose "${INFO}Creating docker volume '${SPRYKER_DOCKER_PREFIX}_assets'${NC}"
    docker volume rm "${volumeName}" > /dev/null || true
    docker volume create --name="${volumeName}"

    verbose "${INFO}Generating assets${NC}"

    docker build -t "${imageName}:${SPRYKER_DOCKER_TAG}" \
        --build-arg SPRYKER_DOCKER_PREFIX="${SPRYKER_DOCKER_PREFIX}" \
        --build-arg SPRYKER_DOCKER_TAG="${SPRYKER_DOCKER_TAG}" \
        --build-arg DEPLOYMENT_PATH="${DEPLOYMENT_PATH}" \
        --build-arg SPRYKER_PLATFORM_IMAGE="${SPRYKER_PLATFORM_IMAGE}" \
        --build-arg MODE="${2:-development}" \
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
}

export -f buildAssets
export -f exportAssets
