#!/bin/bash

declare -a TRAP_ON_EXIT

# Adds an on-exit hook and refers it by the given name
# @param[1] name - Only letters/numbers allowed
# @param[2] command - Only 1 command is allowed. '|', '>', '<', '||', '&&' will not work. Single quote ' will not work too.
#                     Use named function for complex logic:
#                     function myCleanup() {
#                         remove something > /dev/null && cleanup something > /dev/null || true
#                     }
#                     Registry::Trap::addExit myCleanup
function Registry::Trap::addExitHook() {
    local name=$1
    local command=$2

    TRAP_ON_EXIT+=( "name='${name}';command='${command}';" )

    return "${TRUE}"
}

# Disable the hook by the given name
# @param[1] name
function Registry::Trap::removeExitHook() {
    local requiredName=$1

    TRAP_ON_EXIT=( "${TRAP_ON_EXIT[@]/name=\'${requiredName}\';/name='';}" )

    return "${TRUE}"
}

# Execute and disable the hook by the given name
# @param[1] name
function Registry::Trap::releaseExitHook() {
    local requiredName=$1

    for record in "${TRAP_ON_EXIT[@]}"; do
        local name=''
        local command=''
        eval "${record}"
        if [ -n "${name}" ] && [ "${name}" == "${requiredName}" ]; then
            ${command}
        fi
    done

    Registry::Trap::removeExitHook "$@"

    return "${TRUE}"
}

# Execute all on-exit hooks
function Registry::Trap::onExit() {
    set +e
    for record in "${TRAP_ON_EXIT[@]}"; do
        local name=''
        local command=''
        eval "${record}"
        if [ -n "${name}" ]; then
            ${command}
        fi
    done
    set -e

    TRAP_ON_EXIT=()
}

# Using trap for the following signals in other places will broke this functionality
trap Registry::Trap::onExit SIGINT SIGQUIT SIGTSTP EXIT
