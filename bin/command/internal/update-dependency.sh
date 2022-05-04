#!/bin/bash

Registry::addCommand "update-dependency" "Command::updateDependency"

function Command::updateDependency() {
  local forceArg=${1}
  local promptAnswer=${FALSE}

  local gitDockerFilePath='./.git.docker'
  local dockerSdkDirPath='./docker'

  local projectDockerHash
  local dockerSdkLastHash
  projectDockerHash=$(<${gitDockerFilePath})
  dockerSdkLastHash=$(cd ${dockerSdkDirPath} && git rev-parse HEAD)

  if [ "${projectDockerHash}" == "${dockerSdkLastHash}" ]; then
    return ${TRUE}
  fi

  if [ "${forceArg}" == "--f" ]; then
    promptAnswer=${TRUE}
  else
    Console::warn "Project docker hash: ${projectDockerHash}"
    Console::warn "DockerSDK hash: ${dockerSdkLastHash}"

    read -rp "Update dependency in .git.docker? [y/N] " choice
    case "${choice}" in
    y | Y)
      promptAnswer=${TRUE}
      ;;
    n | N)
      promptAnswer=${FALSE}
      ;;
    *)
      promptAnswer=${FALSE}
      ;;
    esac
  fi

  if [ "${promptAnswer}" == "${TRUE}" ]; then
    printf '%s\n' "${dockerSdkLastHash}" >"${gitDockerFilePath}"
  fi
}
