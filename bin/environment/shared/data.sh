#!/bin/bash

function Environment::Shared::Data::bootstrap() {
  local sharedDataDirectory
  sharedDataDirectory="$(Environment::Shared::Data::getPath)"

  if [ ! -d "${sharedDataDirectory}" ]; then
    mkdir -p "${sharedDataDirectory}"
  fi
}

function Environment::Shared::Data::createDirectory() {
  local directoryName="${1}"
  local sharedDataDirectory
  sharedDataDirectory="$(Environment::Shared::Data::getPath)"

  if [ ! -d "${sharedDataDirectory}/${directoryName}" ]; then
    mkdir -p "${sharedDataDirectory}/${directoryName}"
  fi
}

function Environment::Shared::Data::removeDirectory() {
  local directoryName="${1}"
  local sharedDataDirectory
  local fullDirectoryPath

  sharedDataDirectory="$(Environment::Shared::Data::getPath)"
  fullDirectoryPath="${sharedDataDirectory}/${directoryName}"

  if [ -d "${fullDirectoryPath}" ]; then
    rm -rf "${fullDirectoryPath}"
  fi
}

function Environment::Shared::Data::getPath() {
  echo "/tmp/${SPRYKER_DOCKER_SDK_NAME}"
}
