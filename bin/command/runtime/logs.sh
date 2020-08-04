#!/bin/bash

Registry::addCommand "logs" "Command::logs"

Registry::Help::command -c "logs" "Tails all application exception logs."

function Command::logs() {

    local answer=y

    if [ -n "${SPRYKER_DASHBOARD_ENDPOINT}" ]; then

        Console::info "All logs are now available at ${SPRYKER_DASHBOARD_ENDPOINT}/logs"

        Console::warn ""
        Console::warn "Do you still want to tail \`exception.log\` files (y/n)?"
        read answer
    fi

    if [ "$answer" != "${answer#[Yy]}" ] ;then
        # shellcheck disable=SC2016
        Compose::exec 'touch ${SPRYKER_LOG_DIRECTORY}/exception.log && find ${SPRYKER_LOG_DIRECTORY} -type f \( -name "exception.log" \) -exec tail -f "${file}" 2>/dev/null {} +'
    fi

    return "${TRUE}"
}
