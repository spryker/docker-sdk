#!/bin/bash

Registry::addCommand "wait" "Command::wait"

Registry::Help::command -c "wait" -a "service [service...]" "Waits for requested services, e.g. ${HELP_HIGH}${SELF_SCRIPT} wait database broker${HELP_DESC}."

function Command::wait() {
    if [ "$#" == 0 ]; then

        Console::log "${WARN}\`${SELF_SCRIPT} wait\` requires at least 1 argument.${NC}"
        Console::log "${INFO}Example of usage: ${GREEN}${SELF_SCRIPT} wait database broker${NC}"

        exit 1
    fi

    Console::verbose "${INFO}Checking services...${NC}"
    for service in "${@}"; do
        Runtime::waitFor "${service}"
        Console::verbose "${OK}\`${service}\` [OK]${NC}"
    done

    return "${TRUE}"
}
