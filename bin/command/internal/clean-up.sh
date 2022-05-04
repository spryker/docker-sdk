#!/bin/bash

Registry::addCommand "clean-up" "Command::cleanUp"

function Command::cleanUp() {
  local forceArg=${1}

  Command::prune ${forceArg}
  dropDirectory 'vendor/' ${forceArg}
  dropDirectory 'src/Generated/' ${forceArg}
  dropDirectory 'node_modules/' ${forceArg}
  dropDirectory 'public/*/assets/' ${forceArg}
}

function dropDirectory() {
  local directoryPath=${1}
  local forceArg=${2}
  local promptAnswer=${FALSE}
  local choice

  if [ "${forceArg}" == "--f" ]; then
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
    rm -rf "${directoryPath}"
  fi
}
