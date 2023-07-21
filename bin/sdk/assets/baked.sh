#!/bin/bash

function Assets::export() {
    # deprecated
    local TARGET_TAG=${1:-${SPRYKER_DOCKER_TAG}}
    local destination=${2}
    local destinationPath=${3%/}

    local builderAssetsImage
    local dockerAssetsTmpDirectory="/_tmp"
    local projectDockerAssetsTmpDirectory=${DEPLOYMENT_DIR}${dockerAssetsTmpDirectory}

    rm -rf "${projectDockerAssetsTmpDirectory}"
    mkdir -p "${projectDockerAssetsTmpDirectory}"

    local command="true"
    for entrypoint in "${SPRYKER_ENTRYPOINTS[@]}"; do
        command="${command} && \$([ -d '/data/public/${entrypoint}/assets' ] && tar czf '/data${dockerAssetsTmpDirectory}/assets-${entrypoint}-${tag}.tar' -C '/data/public/${entrypoint}/assets' . || true)"
    done

    Console::start "Preparing assets archives..."

    source ${DEPLOYMENT_PATH}/images/export/${destination}.sh

    local targetData
    for targetData in "${TARGET_TAGS[@]}"; do
        eval "${targetData}"

        if [ "$TARGET" == 'frontend' ]; then
            builderAssetsImage="${TAGS[0]}"
            break
        fi
    done

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
        --name="${SPRYKER_DOCKER_PREFIX}_frontend" \
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

function Assets::areBuilt() {
    # Do nothing as everything is built before. Could be changed once assets are separated
    :
}

function Assets::build() {
    # Do nothing as everything is built before. Could be changed once assets are separated
    :
}
