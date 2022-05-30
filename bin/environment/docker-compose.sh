#!/bin/bash

export COMPOSE_HTTP_TIMEOUT=400
export COMPOSE_CONVERT_WINDOWS_PATHS=1

require docker-compose tr

function Environment::checkDockerComposeVersion() {
    Console::verbose::start "Checking docker-compose version..."

    local requiredMinimalVersion=${1:-'1.22.0'}
    local installedVersion=$(
        command -v docker-compose >/dev/null
        test $? -eq 0 && docker-compose version --short || echo 0
    )

    if [ "${installedVersion}" == 0 ]; then
        Console::error "Docker Compose is not found. Please, make sure Docker Compose is installed."
        exit 1
    fi

    if [ "$(Version::parse "${installedVersion}")" -lt "$(Version::parse "${requiredMinimalVersion}")" ]; then
        Console::error "Docker Compose version ${installedVersion} is not supported. Please update Docker Compose to at least ${requiredMinimalVersion}."
        exit 1
    fi

    updateComposeCovertWindowsPaths

    Console::end "[OK]"
}

# https://github.com/docker/compose/issues/9428
function updateComposeCovertWindowsPaths() {
    local dockerComposeVersion="2.5.0"

    if [ "$(Version::parse "${installedVersion}")" -ge "$(Version::parse "${dockerComposeVersion}")" ]; then
        export COMPOSE_CONVERT_WINDOWS_PATHS=0
    fi
}

Registry::addChecker 'Environment::checkDockerComposeVersion'
