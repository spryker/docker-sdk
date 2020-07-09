#!/bin/bash

function Command::unknown() {
    local command=${1}
    shift || true

    $(Registry::findCommand 'help') "${@}"
    Console::error "${WARN}Unknown command \"${command}\" is requested.${NC}"
    exit 1
}
