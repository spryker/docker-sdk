#!/bin/bash

Registry::addCommand "prune" "Command::prune"

function Command::prune() {
    Compose::down
    sync clean # TODO deprecated, use Registry::Flow::addAfterDown in mounts
    Console::error "This will delete ALL docker images and volumes on the host."
    docker image prune
    docker volume prune
    docker system prune -a
    docker builder prune -a

    return "${TRUE}"
}
