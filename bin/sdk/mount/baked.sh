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
  local volumeNames=($(docker volume ls --filter "name=${SPRYKER_PROJECT_NAME}" --format "{{.Name}}"))

  for volumeName in "${volumeNames[@]}" ; do
    if [ -z "${volumeName##*'_data_sync'*}" ] || [ -z "${volumeName##*'_logs'*}" ] || [ -z "${volumeName##*'_cli_history'*}" ] ;then
      continue
    fi

    docker volume rm "${volumeName}"
  done
}
