#!/bin/bash

DOCKER_SDK_NETWORK_NAME="spryker_docker_sdk"
SPRYKER_TRAEFIK_CONTAINER_NAME='spryker_docker_sdk_traefik'


if [ ! "$(docker network ls -q -f name="${DOCKER_SDK_NETWORK_NAME}")" ]; then
    docker network create ${DOCKER_SDK_NETWORK_NAME}
fi

function Traefik::up() {
  if [ "${SPRYKER_TRAEFIK_ENABLE}" = "0" ]; then
    return
  fi

  local isTraefikContainerExist=$(docker ps --filter "name=${SPRYKER_TRAEFIK_CONTAINER_NAME}" --format "{{.Names}}")
  local isTraefikRunning=$(docker ps --filter "name=${SPRYKER_TRAEFIK_CONTAINER_NAME}" --filter "status=running" --format "{{.Names}}")

  if [ -n "${isTraefikRunning}" ]; then
    return
  fi

  if [ -n "${isTraefikContainerExist}" ]; then
    ${DOCKER_COMPOSE_SUBSTITUTE:-'docker-compose'} \
      --project-name "${SPRYKER_TRAEFIK_CONTAINER_NAME}" \
      -f "${DEPLOYMENT_PATH}/docker-compose.traefik.yml" \
      up -d

      return
  fi

  ${DOCKER_COMPOSE_SUBSTITUTE:-'docker-compose'} \
    --project-name "${SPRYKER_TRAEFIK_CONTAINER_NAME}" \
    -f "${DEPLOYMENT_PATH}/docker-compose.traefik.yml" \
    up -d
}

function Traefik::down() {
  if [ "${SPRYKER_TRAEFIK_ENABLE}" = "0" ]; then
    return
  fi

  local isTraefikContainerExist=$(docker ps --filter "name=${SPRYKER_TRAEFIK_CONTAINER_NAME}" --format "{{.Names}}")
  local isTraefikRunning=$(docker ps --filter "name=${SPRYKER_TRAEFIK_CONTAINER_NAME}" --filter "status=running" --format "{{.Names}}")

  if [ -z "${isTraefikContainerExist}" ]; then
    return
  fi

  if [ -n "${isTraefikRunning}" ]; then
    ${DOCKER_COMPOSE_SUBSTITUTE:-'docker-compose'} \
      --project-name "${SPRYKER_TRAEFIK_CONTAINER_NAME}" \
      -f "${DEPLOYMENT_PATH}/docker-compose.traefik.yml" \
      down
  fi
}
