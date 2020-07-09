#!/bin/bash

declare -a INSTALLER_FUNCTIONS

function Registry::addInstaller() {
    local func=$1

    INSTALLER_FUNCTIONS+=("${func}")

    return "${TRUE}"
}

function Registry::runInstallers() {
    local func=''
    local result=1

    for func in "${INSTALLER_FUNCTIONS[@]}"; do
        ${func} "${@}" || result=''
    done

    if [ -n "${result}" ]; then
        return "${FALSE}"
    fi

    return "${TRUE}"
}
