#!/usr/bin/env bash

Registry::addCommand "exec" "Command::exec"

Registry::Help::command -c "exec" -a "<service> <command>" "Execute a command in the specified ${HELP_HIGH}<service>${NC} that is SERVICE name shown in ${HELP_HIGH}${SELF_SCRIPT} ps${NC}"

function Command::exec() {
    Compose::performExec "${@}"

    return "${TRUE}"
}
