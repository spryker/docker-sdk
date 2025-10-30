#!/usr/bin/env bash

require docker

import environment/get-real-project-path.sh

function sync() {
    case $1 in
        create)
            Console::verbose "${INFO}Creating 'data-sync' volume${NC}"
            docker volume create --driver local --opt type=nfs \
                --opt o=addr=host.docker.internal,rw,nolock,fsc,ac,cto,hard,noatime,nointr,nfsvers=3 \
                --opt device=":$(Environment::getRealProjectPath)" \
                --name="${SPRYKER_SYNC_VOLUME}" \
                >/dev/null
            ;;

        clean)
            docker volume rm "${SPRYKER_SYNC_VOLUME}" >/dev/null 2>&1 || true
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
