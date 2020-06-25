#!/bin/bash

Registry::addCommand "clean" "Command::clean"

Registry::Help::command -c "clean" "Stops all Spryker containers and remove images and volumes."

function Command::clean() {
    Compose::cleanEverything
    sync clean
    Images::destroy

    return "${TRUE}"
}
