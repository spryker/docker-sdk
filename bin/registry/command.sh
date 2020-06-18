#!/bin/bash

declare -a COMMAND_FUNCTIONS

function Registry::addCommand() {
    local name=$1
    local func=$2

    COMMAND_FUNCTIONS+=("local name='${name}'; local func='${func}'")

    return "${TRUE}"
}

function Registry::findCommand() {
    local command=$1
    shift || true

    for record in "${COMMAND_FUNCTIONS[@]}"; do
        local name=''
        local func=''
        eval "${record}"

        if [ "${name}" == "${command}" ]; then
            echo -n "${func}"
            break
        fi
    done

    return "${TRUE}"
}
