#!/bin/bash

Registry::addCommand "prune" "Command::prune"
Registry::Help::command -c "prune [--f] [--a]" "Remove all docker data(images, volume, system and builder) and project artifacts."

function Command::prune() {
    local forceArg=''
    local artifactsArg=${FALSE}

    for ARG in "$@"; do
      if [ "${ARG}" == '--f' ]; then
        forceArg='-f'
      fi

      if [ "${ARG}" == '--a' ]; then
        artifactsArg=${TRUE}
      fi
    done

    Compose::down
    sync clean # TODO deprecated, use Registry::Flow::addAfterDown in mounts
    Console::error "This will delete ALL docker images and volumes on the host."
    docker image prune ${forceArg}
    docker volume prune ${forceArg}
    docker system prune -a ${forceArg}
    docker builder prune -a ${forceArg}

    if [ "${artifactsArg}" == "${TRUE}" ]; then
      Command::_prune_artifacts ${forceArg}
    fi

    return "${TRUE}"
}

function Command::_prune_artifacts() {
  local forceArg=${1}

  Command::_dropDirectory 'vendor/' ${forceArg}
  Command::_dropDirectory 'src/Generated/' ${forceArg}
  Command::_dropDirectory 'node_modules/' ${forceArg}
  Command::_dropDirectory 'public/*/assets/' ${forceArg}
}

function Command::_dropDirectory() {
  local directoryPath=${1}
  local forceArg=${2}
  local promptAnswer=${FALSE}
  local choice
  local dirSize=0B

  if [ "${forceArg}" == "-f" ]; then
    promptAnswer=${TRUE}
  else
    read -rp "Drop '${directoryPath}'? [y/N] " choice
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
    if [ -n "$(ls -d ${directoryPath} 2> /dev/null)" ]; then
      dirSize=$(du -sch ${directoryPath} | grep total | cut -f -1)
    fi

    rm -rf ${directoryPath}
  fi

  echo "Total reclaimed space: ${dirSize}"
}
