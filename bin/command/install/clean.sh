#!/bin/bash

Registry::addCommand "clean" "Command::clean"

Registry::Help::command -c "clean" "Stops all Spryker containers and remove images and volumes."

function Command::clean() {
    Compose::cleanEverything
    sync clean # TODO deprecated, use Registry::Flow::addAfterDown in mounts
    Images::destroy

    return "${TRUE}"
}
