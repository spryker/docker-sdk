#!/bin/bash

function SDK::ProjectManager::Project::init() {
    SDK::ProjectManager::Image::exec 'project_init' "${@}"
}

function SDK::ProjectManager::Project::boot() {
    SDK::ProjectManager::Image::exec 'project_boot' "${@}"
}

function SDK::ProjectManager::Project::get_name() {
    SDK::ProjectManager::Image::exec 'project_get_name' "${@}"
}

function SDK::ProjectManager::Project::info() {
    SDK::ProjectManager::Image::exec 'project_info' "${@}"
}

function SDK::ProjectManager::DB::migration() {
    SDK::ProjectManager::Image::exec 'migration' "${@}"
}

function SDK::ProjectManager::Image::get_name() {
    echo "${DOCKER_SDK__PROJECT_NAME}_project_manager"
}

function SDK::ProjectManager::Image::build() {
    local context_path="${SOURCE_DIR}"
    local hash_targets="${MODULES_DIR}/project_manager"
    local dockerfile_path="${MODULES_DIR}/project_manager/Dockerfile"

    Image::build "${context_path}" "$(SDK::ProjectManager::Image::get_name)" "${hash_targets}" "${dockerfile_path}"
}

function SDK::ProjectManager::Image::exec() {
    SDK::ProjectManager::Image::build

    docker run -it --rm \
        -v "${DATA_DIR}:/data" \
        -v "${DEPLOYMENT_DIR}:/deployment" \
        -v "${CONFIG_DIR}:/config" \
        "$(SDK::ProjectManager::Image::get_name)" "${@}"
}

SDK::ProjectManager::Image::build
