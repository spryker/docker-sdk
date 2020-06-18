#!/bin/bash

Registry::addCommand "cli" "Command::cli"

Registry::Help::command -c "cli" "Starts a new container where you can run cli commands."
Registry::Help::command -c "cli" -a "<command>" "Runs a cli command, e.g. ${HELP_HIGH}${SELF_SCRIPT} cli composer install${HELP_DESC}."

function Command::cli() {
    readonly SPRYKER_XDEBUG_ENABLE_FOR_CLI="$([ "${SPRYKER_XDEBUG_ENABLE}" -eq 1 ] && echo '1' || echo '')"

    Compose::ensureCliRunning
    Compose::exec "${@}"
}
