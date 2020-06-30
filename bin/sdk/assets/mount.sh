#!/bin/bash

function Assets::export() {
    # nothing to do
    # deprecated
    return "${FALSE}"
}

function Assets::getImageTag() {
    echo -n "${SPRYKER_DOCKER_PREFIX}_cli:${SPRYKER_DOCKER_TAG}"
}

function Assets::areBuilt() {
    Console::start "Checking assets are built..."

    [ -d public/Yves/assets ] && [ -d public/Zed/assets ] && Console::end "[BUILT]" && return "${TRUE}" || return "${FALSE}"
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

    local mode=${SPRYKER_ASSETS_MODE:-development}

    Compose::ensureCliRunning
    Compose::exec "vendor/bin/install -r ${SPRYKER_PIPELINE} -s build-static -s build-static-${mode}"
}
