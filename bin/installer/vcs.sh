#!/bin/bash

require node npm

function Installer::vcs() {

    if [ -z "${GITHUB_TOKEN}" ]; then
        Console::error "${WARN}Warning: GITHUB_TOKEN is not set but may be required.${NC}"
        return "${FALSE}"
    fi

    return "${TRUE}"
}

Registry::addInstaller "Installer::vcs"
