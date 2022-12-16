#!/bin/bash

function Service::isServiceExist() {
  local serviceName="${1}"

  local isServiceExist=$(Compose::command config --services | grep "${serviceName}")

  if [ -z "${isServiceExist}" ]; then
        return ${FALSE};
  fi

  return ${TRUE}
}
