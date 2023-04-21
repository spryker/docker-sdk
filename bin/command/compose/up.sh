#!/bin/bash

Registry::addCommand "up" "Command::up"

Registry::Help::command -c "up" -a "" "Builds and runs Spryker applications based on demo data. "
Registry::Help::command -c "  " -a "[--build] [--assets] [--data] [--jobs]" "Re-executes the sections specified as options even if they have been executed before."

function Command::up() {
    Compose::up "${@}"

    return "${TRUE}"
}
