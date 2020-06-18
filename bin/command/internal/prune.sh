#!/bin/bash

Registry::addCommand "prune" "Command::prune"

function Command::prune() {
    Compose::down
    sync clean
    Console::error "This will delete ALL docker images and volumes on the host."
    docker image prune
    docker volume prune
    docker system prune -a

    return "${TRUE}"
}
