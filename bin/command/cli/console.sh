#!/bin/bash

Registry::addCommand "console" "Command::console"

Registry::Help::command -c "console" "Runs a Spryker console command, e.g. ${HELP_HIGH}${SELF_SCRIPT} console transfer:generate -vvv${HELP_DESC}."

function Command::console() {
    Compose::ensureCliRunning

    # shellcheck disable=SC2034
    SPRYKER_XDEBUG_ENABLE_FOR_CLI="${SPRYKER_XDEBUG_ENABLE}"
    # shellcheck disable=SC2034
    SPRYKER_TESTING_ENABLE_FOR_CLI="${SPRYKER_TESTING_ENABLE}"

    Compose::exec console "${@}"
}
