#!/bin/bash

function Gateway::rebuild(){
    return 0
}

function Gateway::Images::build() {
    local gatewayImage="${DOCKER_SDK__PROJECT_NAME}_gateway"

    Console::verbose "${INFO}Building Gateway image${NC}"

    docker build \
        -t "${gatewayImage}" \
        -f "${SOURCE_DIR}/images/common/gateway/Dockerfile" \
        --progress="tty" \
        "${DEPLOYMENT_PATH}/context" 1>&2
}
