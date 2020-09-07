#!/bin/bash

Registry::addCommand "trouble" "Command::trouble"

function Command::trouble() {
    Compose::down
    sync clean # TODO deprecated, use Registry::Flow::addAfterDown in mounts

    return "${TRUE}"
}
