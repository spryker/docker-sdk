#!/bin/bash

function SDK::SharedServices::Test() {
    SDK::SharedServices::Container::exec 'test' "${@}"
}

function SDK::SharedServices::Image::get_tag() {
    echo "${DOCKER_SDK__PROJECT_NAME}_shared_services"
}

function SDK::SharedServices::Image::build() {
    local context_path="${SOURCE_DIR}"
    local hash_targets="${MODULES_DIR}/shared_services"
    local dockerfile_path="${MODULES_DIR}/shared_services/Dockerfile"

    Image::build "${context_path}" "$(SDK::SharedServices::Image::get_tag)" "${hash_targets}" "${dockerfile_path}"
}

function SDK::SharedServices::Container::exec() {
    SDK::SharedServices::Image::build

    docker run -it --rm \
        -v "${DATA_DIR}:/sdk/data" \
        -v "${DEPLOYMENT_DIR}:/sdk/deployment" \
        -v "${CONFIG_DIR}:/sdk/config" \
        -v "${SOURCE_DIR}/generator/src/templates:/sdk/templates" \
        "$(SDK::SharedServices::Image::get_tag)" "${@}"
}

SDK::SharedServices::Image::build
