#!/bin/bash

readonly DOCKER_SDK_PATH="${HOME}/.docker-sdk"
readonly DOCKER_SDK_REPO="git@github.com:spryker/docker-sdk.git"
readonly DOCKER_SDK_ALIAS="alias docker/sdk"
readonly DOCKER_SDK_ALIAS_WITH_VALUE="${DOCKER_SDK_ALIAS}='${DOCKER_SDK_PATH}/sdk'"

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

function registrationAlias() {
  local profilePath=$(getProfileFile)
  local isAliasExist=$(cat "${profilePath}" | grep "${DOCKER_SDK_ALIAS}")

  if [ -z "${isAliasExist}" ]; then
      echo "${DOCKER_SDK_ALIAS_WITH_VALUE}" >> "${profilePath}"
      ${SHELL} -c "source ${profilePath}"
  else
    if [ "${isAliasExist}" != "${DOCKER_SDK_ALIAS_WITH_VALUE}" ]; then
      printf "WARNING: Your 'docker/sdk' alias has wrong value. Please update your shell profile with next value: %s" "${DOCKER_SDK_ALIAS_WITH_VALUE}"
    fi
  fi
}

function install() {
  cleanUpOlderVersion
  clone
  registrationAlias
}

install
