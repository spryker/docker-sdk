#!/bin/bash

function SDK::Docker::Network::create() {
    if [ -z "${DOCKER_SDK__DOCKER__NETWORKS}" ]; then
        Console::error "DOCKER_SDK__GLOBAL__NETWORKS is not set. Please check your configuration."
    fi

    for network_name in ${DOCKER_SDK__DOCKER__NETWORKS[@]}; do
        if [ -n "$(docker network ls -q -f name="${network_name}")" ]; then
            continue
        fi

        Console::start "${GREEN}\`${network_name}\` network is creating...${NC}"
        docker network create "${network_name}" >/dev/null
        Console::end "[OK]"
    done
}
