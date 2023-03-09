#!/bin/bash

function Service::isServiceExist() {
  local serviceName="${1}"

  local isServiceExist=$(Compose::command config --services | grep "${serviceName}")

  echo "------------------------------| serviceName - ${serviceName} | isServiceExist - ${isServiceExist} |------------------------------"

  if [ -z "${isServiceExist}" ]; then
        echo "------------------------------| serviceName - ${serviceName} | not available |------------------------------"
        return ${FALSE};
  fi

  return ${TRUE}
}
