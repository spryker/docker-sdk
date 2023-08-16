#!/bin/bash

IMAGE_TAG="${DOCKER_SDK__PROJECT_NAME}_gateway"

function build_image() {
    local context_path="${SOURCE_DIR}"
    local hash_targets="${MODULES_DIR}/gateway"
    local dockerfile_path="${MODULES_DIR}/gateway/Dockerfile"

    Image::build "${context_path}" "${IMAGE_TAG}" "${hash_targets}" "${dockerfile_path}"
}

function exec() {
    build_image

    docker run -it --rm \
        -v "${DATA_DIR}:/gateway/data" \
        -v "${DEPLOYMENT_DIR}:/gateway/deployment" \
#        -v "${CONFIG_DIR}:/gateway/config" \
        "${IMAGE_TAG}" "${@}"
}
