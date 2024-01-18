#!/bin/bash

function Gateway::setupProjectConfig() {
  local generatedGatewayContextPath="${DEPLOYMENT_PATH}/context/${GATEWAY_DIR_NAME}"
  local gatewaySharedDataPath="$(Environment::Shared::Data::getPath)/${GATEWAY_DIR_NAME}"
  local gatewaySharedConfigPath="${gatewaySharedDataPath}/${GATEWAY_CONFIG_NAME}"

  cp "${generatedGatewayContextPath}/${COMPOSE_PROJECT_NAME}.yml" "${gatewaySharedConfigPath}/${COMPOSE_PROJECT_NAME}.yml"
}

function Gateway::setupCerts() {
  local sslDir="${DEPLOYMENT_PATH}/context/nginx/ssl"
  local gatewaySharedDataPath="$(Environment::Shared::Data::getPath)/${GATEWAY_DIR_NAME}"
  local gatewaySharedCertPath="${gatewaySharedDataPath}/${GATEWAY_CERT_DIR_NAME}"

  cp "${sslDir}/ssl.key" "${gatewaySharedCertPath}/${COMPOSE_PROJECT_NAME}.key"
  cp "${sslDir}/ssl.crt" "${gatewaySharedCertPath}/${COMPOSE_PROJECT_NAME}.crt"
}

function Gateway::up() {
  local gatewaySharedDataPath="$(Environment::Shared::Data::getPath)/${GATEWAY_DIR_NAME}"
  local gatewaySharedConfigPath="${gatewaySharedDataPath}/${GATEWAY_CONFIG_NAME}"

  if [ "$(docker ps -q -f name="${GATEWAY_CONTAINER_NAME}")" ]; then
    return
  fi

  docker-compose --project-name "${SPRYKER_DOCKER_SDK_NAME}" -f "${gatewaySharedDataPath}/${GATEWAY_COMPOSE_FILE_NAME}" up -d
}

function Gateway::down() {
  local gatewaySharedDataPath="$(Environment::Shared::Data::getPath)/${GATEWAY_DIR_NAME}"

#  todo: check projects

  if [ ! "$(docker ps -q -f name="${GATEWAY_CONTAINER_NAME}")" ]; then
    return
  fi

  docker-compose --project-name "${SPRYKER_DOCKER_SDK_NAME}" -f "${gatewaySharedDataPath}/${GATEWAY_COMPOSE_FILE_NAME}" down
}

Registry::Flow::addBeforeUp "Gateway::setupProjectConfig"
Registry::Flow::addBeforeUp "Gateway::setupCerts"

Registry::Flow::addAfterUp "Gateway::up"
Registry::Flow::addAfterDown "Gateway::down"
