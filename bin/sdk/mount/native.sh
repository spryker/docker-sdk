#!/bin/bash

function Mount::logs() {
    Console::error "This mount mode does not support logging."
    exit 1
}

function sync() {
    # @deprecated

    return "${TRUE}"
}

function Mount::dropVolumes() {
  docker volume rm $(docker volume ls --filter "name=${SPRYKER_PROJECT_NAME}" --format "{{.Name}}")
}
