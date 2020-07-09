#!/bin/bash

Registry::addCommand "install" "Command::install"

Registry::Help::command -c "install" "Lists instructions to configure host environment."

function Command::install() {
    local output=''

    if ! output=$(Registry::runInstallers); then
        Console::info 'Everything is properly installed. Nothing to do at the momemnt.'
        return "${TRUE}"
    fi

    if [ -z "${output}" ]; then
        return "${TRUE}"
    fi

    Console::info "${INFO}Please, run the following commands in order to prepare the environment:" >/dev/stderr
    Console::log "${BLOCKDARK}${output}\n${NC}\n\n" >/dev/stderr

    return "${TRUE}"
}
