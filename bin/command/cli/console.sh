#!/bin/bash

Registry::addCommand "console" "Command::console"

Registry::Help::command -c "console" "Runs a Spryker console command, e.g. ${HELP_HIGH}${SELF_SCRIPT} console transfer:generate -vvv${HELP_DESC}."

function Command::console() {
    readonly SPRYKER_XDEBUG_ENABLE_FOR_CLI="$([ "${SPRYKER_XDEBUG_ENABLE}" -eq 1 ] && echo '1' || echo '')"

    Compose::ensureCliRunning
    Compose::exec console "${@}"
}
