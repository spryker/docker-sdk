#!/bin/bash

set -e

pushd ${BASH_SOURCE%/*} > /dev/null
. ../constants.sh
. ../console.sh

../require.sh docker mutagen go
popd > /dev/null

function progress()
{
    local message='Data is syncing'
    local ms=0
    local sec=0

    while :;do
        ((ms++))

        if [ "${ms}" == 10 ]; then
            ((sec++))
            ms=0
        fi

        echo -ne "\r${message} (${sec}.${ms} sec)"
        sleep 0.1
    done
}

function checkSyncByProjectName()
{
    local projectName=$1
    local waitingStatus='Status: Watching for changes'

    count=0
    maxCount=3

    while true; do
        command=$(mutagen sync list ${projectName} | grep Status:)

        if [ "${count}" == "${maxCount}" ]; then
            break;
        fi

        if [ ! "${command}" == "${waitingStatus}" ]; then
            count=0
        fi

        if [ "${command}" == "${waitingStatus}" ]; then
            ((count++))
        fi

        sleep 1
    done
}

function checkAllSyncProcesses()
{
    local syncConf="${DEPLOYMENT_PATH}/mutagen.yml"

    oldIFS=${IFS}
    IFS=$'\n'

    pattern="Name: "
    projects=($(mutagen project list ${syncConf} | grep ${pattern}))

    IFS=${oldIFS}

    trap 'kill $progressPID; exit' INT
    progress &
    progressPID=$!

    processes=()
    for i in "${projects[@]}"; do
        checkSyncByProjectName "${i//${pattern}}" &
        processes+=($!)
    done

    for i in "${processes[@]}"; do
        while kill -0 $i > /dev/null 2>&1; do
            sleep 1
        done
    done

    kill -13 ${progressPID} > /dev/null 2>&1 || true
    echo " "
    echo 'All data was synced.'
}

function sync()
{
    export DOCKER_SYNC_SKIP_UPDATE=1
    local syncConf="${DEPLOYMENT_PATH}/mutagen.yml"

    case $1 in
        create)
            verbose "${INFO}Creating 'data-sync' volume and sync container${NC}"
            docker volume create --name=spryker_dev_data_sync
            if [ ! "$(docker ps -a | grep spryker_mutagen_sync_1)" ]; then
                docker run -d \
                   --name spryker_mutagen_sync_1 \
                   -v spryker_dev_data_sync:/data \
                   -u 1000:1000 \
                   spryker_cli:dev \
                   nc -l 9000
            fi
            ;;

        recreate)
            mutagen project resume ${syncConf}
            ;;

        clean)
            mutagen project flush ${syncConf}
            docker volume rm ${SPRYKER_DOCKER_PREFIX}_${SPRYKER_DOCKER_TAG}_data_sync || true
            ;;

        stop)
            mutagen project terminate ${syncConf}
            ;;
        *)
            if [ $(docker ps | grep 5000 | grep ${SPRYKER_DOCKER_PREFIX}_${SPRYKER_DOCKER_TAG}_data_sync | wc -l |sed 's/^ *//') -eq 0 ]; then
                verbose "${INFO}Start sync process for data volume${NC}"
                pushd ${PROJECT_DIR} > /dev/null

                mutagen project start ${syncConf} || echo 'Mutagen project already running'
                checkAllSyncProcesses

                popd > /dev/null
            fi
            ;;
    esac
}

export -f sync
