#!/bin/bash

function Installer::vcs() {

    if [ -z "${GITHUB_TOKEN}" ]; then
        Console::error "Warning: GITHUB_TOKEN is not set but may be required."
        return "${FALSE}"
    fi

    return "${TRUE}"
}

Registry::addInstaller "Installer::vcs"
