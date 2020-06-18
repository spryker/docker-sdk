#!/bin/bash

Registry::addCommand "demo" "Command::demo"
Registry::addCommand "demo-data" "Command::demo"

Registry::Help::command -c "demo | demo-data" "Populates Spryker demo data."
Registry::Help::command -c "demo" -a "<section>" "Loads the demo data by running the specified section from docker installation recipe for each store, e.g. ${HELP_HIGH}demo-minimal${HELP_DESC}. "

function Command::demo() {
    Compose::run
    Data::load --force "${1}"

    return "${TRUE}"
}
