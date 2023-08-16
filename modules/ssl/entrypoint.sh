#!/bin/bash

function SSL::generate(){
    SSL::Image::exec "${@}"
}

function SSL::Image::get_name(){
    echo "${DOCKER_SDK__PROJECT_NAME}_ssl"
}

function SSL::Image::build() {
    local context_path="${SOURCE_DIR}"
    local hash_targets="${MODULES_DIR}/ssl"
    local dockerfile_path="${MODULES_DIR}/ssl/Dockerfile"

    Image::build "${context_path}" "$(SSL::Image::get_name)" "${hash_targets}" "${dockerfile_path}"
}

function SSL::Image::exec() {
    SSL::Image::build

    docker run -it --rm \
        -v "${DATA_DIR}:/sdk/data" \
        -v "${DEPLOYMENT_DIR}:/sdk/deployment" \
        "$(SSL::Image::get_name)" "${@}"
}

SSL::Image::build
