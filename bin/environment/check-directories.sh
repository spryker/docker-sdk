#!/bin/bash

function Environment::checkDirectories() {
    local projectDirectoryPath="${1:-$(pwd)}"

    if [ "${projectDirectoryPath}" != "${projectDirectoryPath%[[:space:]]*}" ]; then
        Console::error "The SDK does not support spaces in the path. Please, move your project accordingly."
        exit 1
    fi
}

Registry::addChecker 'Environment::checkDirectories'
