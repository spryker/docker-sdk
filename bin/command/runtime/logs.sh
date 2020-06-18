#!/bin/bash

Registry::addCommand "logs" "Command::logs"

Registry::Help::command -c "logs" "Tails all application exception logs."

function Command::logs() {
    # shellcheck disable=SC2016
    Compose::exec 'find ${SPRYKER_LOG_DIRECTORY} -type f \( -name \"exception.log\" \) -exec tail -f \"${file}\" {} +'

    return "${TRUE}"
}
