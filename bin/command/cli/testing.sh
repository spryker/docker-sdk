#!/bin/bash

Registry::addCommand "testing" "Command::testing"

Registry::Help::command -c "testing" "Starts a new container where you can run cli commands in testing environment, e.g. ${HELP_HIGH}codecept build${HELP_DESC}."
Registry::Help::command -c "testing" -a "<command>" "Runs a cli command in testing environment, e.g. ${HELP_HIGH}${SELF_SCRIPT} testing codecept build${HELP_DESC}."

function Command::testing() {
    readonly SPRYKER_XDEBUG_ENABLE_FOR_CLI="$([ "${SPRYKER_XDEBUG_ENABLE}" -eq 1 ] && echo '1' || echo '')"

    Compose::ensureTestingMode
    Compose::ensureCliRunning

    Runtime::waitFor database
    Runtime::waitFor broker
    Runtime::waitFor search
    Runtime::waitFor key_value_store
    Runtime::waitFor session
    Runtime::waitFor webdriver

    Compose::exec "${@}"
}
