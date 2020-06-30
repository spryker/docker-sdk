#!/bin/bash

Registry::addCommand "down" "Command::down"

Registry::Help::command -c "down" "Stops and removes all Spryker containers."

function Command::down() {
    Compose::down

    return "${TRUE}"
}
