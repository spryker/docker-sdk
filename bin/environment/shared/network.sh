#!/bin/bash

function Environment::Shared::Network::bootstrap() {
  if [ -z "$(docker network ls -q -f name="${SPRYKER_DOCKER_SDK_NETWORK_NAME}")" ]; then
    docker network create "${SPRYKER_DOCKER_SDK_NETWORK_NAME}" 1> /dev/null
  fi
}
