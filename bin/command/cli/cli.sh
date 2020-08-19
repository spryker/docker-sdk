#!/bin/bash

Registry::addCommand "cli" "Command::cli"

Registry::Help::command -c "cli" "Starts a new container where you can run cli commands."
Registry::Help::command -c "cli" -a "<command>" "Runs a cli command, e.g. ${HELP_HIGH}${SELF_SCRIPT} cli composer install${HELP_DESC}."

function Command::cli() {
    Compose::ensureCliRunning
    Compose::exec "${@}"
}
