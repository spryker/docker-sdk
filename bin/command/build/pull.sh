#!/bin/bash

Registry::addCommand "pull" "Command::pull"

Registry::Help::command -c "pull" "Pulls external docker images."

function Command::pull() {
    Images::pull
    Compose::command pull --ignore-pull-failures 2>/dev/null || true

    return "${TRUE}"
}
