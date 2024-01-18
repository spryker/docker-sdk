#!/bin/bash

import environment/shared/data.sh

function Gateway::install() {
  Environment::Shared::Data::createDirectory "${GATEWAY_DIR_NAME}"
  Environment::Shared::Data::createDirectory "${GATEWAY_DIR_NAME}/${GATEWAY_CONFIG_NAME}"
  Environment::Shared::Data::createDirectory "${GATEWAY_DIR_NAME}/${GATEWAY_CERT_DIR_NAME}"

  local gatewaySharedDataPath="$(Environment::Shared::Data::getPath)/${GATEWAY_DIR_NAME}"

  cp "${GATEWAY_CONTEXT_PATH}/${GATEWAY_COMPOSE_FILE_NAME}" "${gatewaySharedDataPath}/${GATEWAY_COMPOSE_FILE_NAME}"
  cp "${GATEWAY_CONTEXT_PATH}/${GATEWAY_CONFIG_FILE_NAME}" "${gatewaySharedDataPath}/${GATEWAY_CONFIG_FILE_NAME}"
}

Registry::addInstaller "Gateway::install"
