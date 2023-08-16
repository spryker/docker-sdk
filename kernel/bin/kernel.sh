#!/bin/bash

. "${SOURCE_DIR}/bin/lib/image.sh"
. "${SDK_DIR}/bin/build.sh"

SDK_GENERATED_CONFIG_PATH="${DATA_DIR}/config.sh"
SDK_GENERATED_MODULES_PATH="${DATA_DIR}/modules.sh"

function SDK::Kernel::bootstrap() {
    SDK::Codebase::Image::build
    SDK::Kernel::Image::build

    SDK::Kernel::Config::bootstrap
    SDK::Kernel::DB::bootstrap
    SDK::Kernel::Modules::bootstrap
}

function SDK::Kernel::Image::build() {
    if [ -z "${SOURCE_DIR}" ]; then
        Console::error "SOURCE_DIR is not set. Please set SOURCE_DIR environment variable."
        exit 1
    fi

    local context="${SOURCE_DIR}"
    local kernelDir="${SOURCE_DIR}/kernel"
    local dockerfile="${kernelDir}/Dockerfile"

    Image::build "${context}" "$(SDK::Kernel::Image::get_tag)" "${kernelDir}" "${dockerfile}"
}

function SDK::Kernel::Container::exec() {
    docker run -it --rm \
        -v "${SOURCE_DIR}/kernel:/kernel" \
        -v "${DATA_DIR}:/data" \
        -v "${DEPLOYMENT_DIR}:/deployment" \
        -v "${CONFIG_DIR}:/config" \
        -v "${MODULES_DIR}:/modules" \
        "$(SDK::Kernel::Image::get_tag)" "${@}"
}

function SDK::Kernel::Image::get_tag() {
    echo 'spryker_docker_sdk_kernel'
}

function SDK::Kernel::Config::bootstrap() {
    local config_path="${CONFIG_DIR}/config.yaml"

    if Hash::isHashChanged "${config_path}"; then
        Console::start "${GREEN}Load Docker SDK config...${NC}"
        SDK::Kernel::Container::exec 'config-build' "${SOURCE_DIR}"
        Console::end "[OK]"
    fi

    source "${SDK_GENERATED_CONFIG_PATH}"
}

function SDK::Kernel::DB::bootstrap() {
    if [ -f "${DATA_DIR}/${DOCKER_SDK__PROJECT_NAME}.db" ]; then
        return "${TRUE}"
    fi

    Console::start "${GREEN}Init Docker SDK DB...${NC}"
    SDK::Kernel::Container::exec 'init-db'
    Console::end "[OK]"
}

function  SDK::Kernel::Modules::bootstrap() {
    if Hash::isHashChanged "${MODULES_DIR}"; then
        Console::start "${GREEN}Load Docker SDK modules...${NC}"
        SDK::Kernel::Container::exec 'modules-load'
        Console::end "[OK]"
    fi

    source "${SDK_GENERATED_MODULES_PATH}"
}
