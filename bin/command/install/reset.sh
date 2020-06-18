#!/bin/bash

Registry::addCommand "reset" "Command::reset"

Registry::Help::command -c "reset" "Removes and builds all Spryker images and volumes."

function Command::reset() {
    Compose::down
    Compose::cleanVolumes
    Assets::destroy
    Compose::up

    return "${TRUE}"
}
