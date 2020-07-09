#!/bin/bash

require docker

import environment/get-real-project-path.sh

function sync() {
    local volumeName="${SPRYKER_DOCKER_PREFIX}_${SPRYKER_DOCKER_TAG}_data_sync"

    case $1 in
        create)
            Console::verbose "${INFO}Creating 'data-sync' volume${NC}"
            docker volume create --driver local --opt type=nfs \
                --opt o=addr=host.docker.internal,rw,nolock,fsc,ac,cto,hard,noatime,nointr,nfsvers=3 \
                --opt device=":$(Environment::getRealProjectPath)" \
                --name="${volumeName}" \
                >/dev/null
            ;;

        clean)
            docker volume rm "${volumeName}" >/dev/null 2>&1 || true
            ;;

        stop) ;;

        logs)
            Console::error "This mount mode does not support logging."
            exit 1
            ;;

        start)
            sync clean
            sync create
            ;;
    esac
}
