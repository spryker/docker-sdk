#!/usr/bin/env bash

require docker docker-sync grep sed

function sync() {
    export DOCKER_SYNC_SKIP_UPDATE=1
    local command=$1
    local syncConf="${DEPLOYMENT_PATH}/docker-sync.yml"
    local syncVolume="${SPRYKER_DOCKER_PREFIX}_${SPRYKER_DOCKER_TAG}_data_sync"

    case "${command}" in
        create)
            Console::verbose "${INFO}Creating 'data-sync' volume${NC}"
            docker volume create --name="${syncVolume}" >/dev/null
            ;;

        recreate)
            sync clean
            sync create
            ;;

        clean)
            docker-sync clean -c "${syncConf}"
            docker volume rm "${syncVolume}" >/dev/null 2>&1 || true
            ;;

        stop)
            docker-sync stop -c "${syncConf}" -n data-sync
            ;;
        init)
            isRunning=$(docker ps -a --filter 'status=running' --filter 'name='"${SPRYKER_DOCKER_PREFIX}_${SPRYKER_DOCKER_TAG}_data_sync" --format "{{.Names}}")
            isExited=$(docker ps -a --filter 'status=exited' --filter 'name='${SPRYKER_DOCKER_PREFIX}_${SPRYKER_DOCKER_TAG}_data_sync --format "{{.Names}}")

            if [ -z "${isRunning}" ] && [ -n "${isExited}" ]; then
                docker rm -f "${SPRYKER_DOCKER_PREFIX}_${SPRYKER_DOCKER_TAG}_data_sync"
            fi
            ;;
        logs)
            docker-sync logs -c "${syncConf}" -f
            ;;
        *)
            local runningSync="$(docker ps | grep 5000 | grep -c "${syncVolume}" | sed 's/^ *//')"
            if [ "$runningSync" -eq 0 ]; then
                Console::verbose "${INFO}Starting sync process${NC}"
                pushd "${PROJECT_DIR}" >/dev/null || true
                docker-sync start -c "${syncConf}"
                popd >/dev/null || true
            fi
            ;;
    esac
}
