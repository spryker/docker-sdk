#!/bin/bash

Registry::addCommand "ps" "Command::ps"

Registry::Help::command -c "ps" "Shows status of Spryker containers."

function Command::ps() {
    Compose::ps "${@}"
    return "${TRUE}"
}
