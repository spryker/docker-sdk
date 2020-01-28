#!/bin/bash

set -e

pushd ${BASH_SOURCE%/*} > /dev/null
. ../constants.sh
. ../console.sh

../require.sh docker mutagen
popd > /dev/null

function progress()
{
    local message='Syncing files'
    local ms=0
    local sec=0

    while :;do
        ms=$(( ms + 1 ))

        if [ "${ms}" == 10 ]; then
            sec=$((sec + 1))
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
        else
            count=$((count + 1))
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
    echo 'All files has been synced.'
}

function isMutagenProjectRunning()
{
    local syncConf="${1:-${DEPLOYMENT_PATH}/mutagen.yml}"

    if [ $(mutagen project list ${syncConf} 2>&1 | grep 'Error: project not running' | wc -l |sed 's/^ *//') -ne 0 ]; then
        return ${__FALSE}
    fi

    return ${__TRUE}
}

function sync()
{
    export DOCKER_SYNC_SKIP_UPDATE=1
    local syncConf="${DEPLOYMENT_PATH}/mutagen.yml"
    local volumeName=${SPRYKER_DOCKER_PREFIX}_${SPRYKER_DOCKER_TAG}_data_sync
    local syncContainerName=${SPRYKER_DOCKER_PREFIX}_${SPRYKER_DOCKER_TAG}_sync

    case $1 in
        create)
            verbose "${INFO}Creating 'data-sync' volume and sync container${NC}"
            docker volume create --name=${volumeName}
            runSyncContainer ${syncContainerName} ${volumeName}
            ;;

        recreate)
            mutagen project resume ${syncConf}
            ;;

        clean)
            if isMutagenProjectRunning; then
                mutagen project flush ${syncConf}
            fi
            docker volume rm ${volumeName} || true
            ;;

        stop)
            if isMutagenProjectRunning; then
                mutagen project terminate ${syncConf}
            fi
            ;;
        init)
            ;;
        *)
            if ! isMutagenProjectRunning; then
                verbose "${INFO}Start sync process for data volume${NC}"
                pushd ${PROJECT_DIR} > /dev/null

                runSyncContainer ${syncContainerName} ${volumeName}
                mutagen project start ${syncConf} || echo 'Mutagen project already running'
                checkAllSyncProcesses

                popd > /dev/null
            fi
            ;;
    esac
}

function runSyncContainer()
{
    if [ ! "$(docker ps | grep ${1})" ]; then
        docker rm ${1} || true
        docker run -d \
           --name ${1} \
           -v ${2}:/data \
           -u 1000:1000 \
           spryker_cli:dev \
           nc -l 9000
    fi
}

export -f sync
