#!/usr/bin/env bash

Registry::addCommand "clean-data" "Command::clean-data"

Registry::Help::command -c "clean-data" "Removes all Spryker volumes including all storages."

function Command::clean-data() {
    Compose::stop
    Compose::cleanVolumes

    return "${TRUE}"
}
