#!/bin/bash

function Assets::init() {
    # TODO investigate why do we need it
    if docker volume inspect "${SPRYKER_DOCKER_PREFIX}_assets" >/dev/null 2>&1; then
        return "${TRUE}"
    fi

    Console::verbose "${INFO}Creating docker volume '${SPRYKER_DOCKER_PREFIX}_assets'${NC}"
    docker volume create --name="${SPRYKER_DOCKER_PREFIX}_assets"
}

function Assets::destroy() {
    # TODO investigate why do we need it
    Console::verbose "${INFO}Removing assets volume${NC}"
    docker volume rm -f "${SPRYKER_DOCKER_PREFIX}_assets" || true
}

function Assets::areBuilt() {
    Console::start "Checking assets are built..."

    [ -d public/Yves/assets ] && Console::end "[BUILT]" && return "${TRUE}" || return "${FALSE}"
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

    local volumeName=${SPRYKER_DOCKER_PREFIX}_assets

    Console::verbose "${INFO}Creating docker volume '${volumeName}'${NC}"
    docker volume create --name="${volumeName}"

    Compose::ensureCliRunning

    Compose::exec "vendor/bin/install -r docker -s build-static -s build-static-${SPRYKER_ASSETS_MODE:-development}"
}
