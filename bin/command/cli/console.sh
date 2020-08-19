#!/bin/bash

Registry::addCommand "console" "Command::console"

Registry::Help::command -c "console" "Runs a Spryker console command, e.g. ${HELP_HIGH}${SELF_SCRIPT} console transfer:generate -vvv${HELP_DESC}."

function Command::console() {
    Compose::ensureCliRunning
    Compose::exec console "${@}"
}
