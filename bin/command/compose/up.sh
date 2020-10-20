#!/bin/bash

Registry::addCommand "up" "Command::up"

Registry::Help::command -c "up [--build] [--assets] [--data] [--jobs]" "Builds and runs Spryker applications based on demo data. Re-executes the sections specified as options even if they have been executed before."

function Command::up() {
    Compose::up "${@}"

    return "${TRUE}"
}
