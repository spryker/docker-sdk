#!/bin/bash

Registry::addCommand "trouble" "Command::trouble"

function Command::trouble() {
    Compose::down
    sync clean

    return "${TRUE}"
}
