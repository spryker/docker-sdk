#!/bin/bash

function Service::Scheduler::isInstalled() {
    [ -n "${SPRYKER_TESTING_ENABLE}" ] && return "${TRUE}"

    Runtime::waitFor scheduler
    Console::start -n "Checking jobs are installed..."

    # shellcheck disable=SC2016
    local jobsCount=$(Compose::exec 'curl -sL ${SPRYKER_SCHEDULER_HOST}:${SPRYKER_SCHEDULER_PORT}/scriptText -d "script=println Jenkins.instance.projects.collect{ it.name }.size" | tail -n 1' | tr -d " \n\r")
    [ "${jobsCount}" -gt 0 ] && Console::end "[INSTALLED]" && return "${TRUE}" || return "${FALSE}"
}

Service::Scheduler::pause() {
    [ -n "${SPRYKER_TESTING_ENABLE}" ] && return "${TRUE}"

    Runtime::waitFor scheduler
    Console::start -n "Suspending scheduler..."

    # shellcheck disable=SC2016
    Compose::exec 'curl -sLI -X POST ${SPRYKER_SCHEDULER_HOST}:${SPRYKER_SCHEDULER_PORT}/quietDown' >/dev/null || true

    # TODO Send SIGTERM in cli-rpc.js
    local counter=1
    local interval=2
    local waitFor=60
    while :; do
        # shellcheck disable=SC2016
        local runningJobsCount=$(Compose::exec 'curl -sL ${SPRYKER_SCHEDULER_HOST}:${SPRYKER_SCHEDULER_PORT}/computer/api/xml?xpath=*/busyExecutors/text\(\) | tail -n 1' | tr -d " \n\r")
        [ "${runningJobsCount}" -eq 0 ] && break
        [ "${counter}" -ge "${waitFor}" ] && break
        counter=$((counter + interval))
        sleep "${interval}"
    done

    Console::end "[DONE]"
}

Service::Scheduler::unpause() {
    [ -n "${SPRYKER_TESTING_ENABLE}" ] && return "${TRUE}"

    Runtime::waitFor scheduler
    Console::start -n "Resuming scheduler..."

    # shellcheck disable=SC2016
    Compose::exec 'curl -sLI -X POST ${SPRYKER_SCHEDULER_HOST}:${SPRYKER_SCHEDULER_PORT}/cancelQuietDown' >/dev/null || true

    Console::end "[DONE]"
}

function Service::Scheduler::start() {

    local force=''
    if [ "$1" == '--force' ]; then
        force=1
        shift || true
    fi

    if [ -z "${force}" ] && Service::Scheduler::isInstalled; then
        return "${TRUE}"
    fi

    Service::Scheduler::_run setup "Creating"
}

function Service::Scheduler::stop() {
    Service::Scheduler::_run suspend "Suspending"
}

function Service::Scheduler::clean() {
    Service::Scheduler::_run clean "Cleaning"
}

function Service::Scheduler::_run() {
    [ -n "${SPRYKER_TESTING_ENABLE}" ] && return "${TRUE}"

    Runtime::waitFor scheduler

    for region in "${SPRYKER_STORES[@]}"; do
        eval "${region}"
        for store in "${STORES[@]}"; do
            SPRYKER_CURRENT_STORE="${store}"
            Console::info "${2} scheduler jobs for ${SPRYKER_CURRENT_STORE} store."
            Compose::exec "vendor/bin/install -r ${SPRYKER_PIPELINE} -s scheduler-${1}"
        done
    done
}
