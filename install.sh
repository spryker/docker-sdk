#!/usr/bin/env bash

set -x

readonly DOCKER_SDK_PATH="${HOME}/.docker-sdk"
readonly DOCKER_SDK_REPO="git@github.com:spryker/docker-sdk.git"
readonly DOCKER_SDK_ALIAS="alias docker/sdk=${DOCKER_SDK_PATH}/sdk"

function cleanUpOlderVersion() {
  rm -rf "${DOCKER_SDK_PATH}"
}

function clone() {
  git clone "${DOCKER_SDK_REPO}" "${DOCKER_SDK_PATH}"
}

function getProfileFile() {
  local profilePath=''

  if [ "${SHELL#*bash}" != "$SHELL" ]; then
    if [ -f "${HOME}/.bashrc" ]; then
      profilePath="${HOME}/.bashrc"
    elif [ -f "${HOME}/.bash_profile" ]; then
      profilePath="${HOME}/.bash_profile"
    fi
  elif [ "${SHELL#*zsh}" != "$SHELL" ]; then
    if [ -f "${HOME}/.zshrc" ]; then
      profilePath="${HOME}/.zshrc"
    elif [ -f "${HOME}/.zprofile" ]; then
      profilePath="${HOME}/.zprofile"
    fi
  fi

  echo ${profilePath}
}

function install() {
  cleanUpOlderVersion
  clone
  profilePath=$(getProfileFile)
  echo "${DOCKER_SDK_ALIAS}" >> "${profilePath}"
  source "${profilePath}"
}

install
