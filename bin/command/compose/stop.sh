#!/bin/bash

Registry::addCommand "stop" "Command::stop"

Registry::Help::command -c "stop" "Stops all Spryker containers."

function Command::stop() {
    Compose::stop

    return "${TRUE}"
}
