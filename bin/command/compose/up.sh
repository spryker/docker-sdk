#!/bin/bash

Registry::addCommand "up" "Command::up"

Registry::Help::command -c "up" "Builds and runs Spryker applications based on demo data."
# TODO
Registry::Help::command -c "up --build --" "Builds and runs Spryker applications based on demo data."

function Command::up() {
    Compose::up "${@}"

    return "${TRUE}"
}
