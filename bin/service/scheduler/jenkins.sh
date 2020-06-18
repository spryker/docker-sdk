#!/bin/bash

function Service::Scheduler::isInstalled() {
    [ "${SPRYKER_TESTING_ENABLE}" -eq 1 ] && return "${TRUE}"

    Runtime::waitFor scheduler
    Console::start -n "Checking jobs are installed..."

    # shellcheck disable=SC2016
    local jobsCount=$(Compose::exec 'curl -sL ${SPRYKER_SCHEDULER_HOST}:${SPRYKER_SCHEDULER_PORT}/scriptText -d "script=println Jenkins.instance.projects.collect{ it.name }.size" | tail -n 1' | tr -d " \n\r")
    [ "${jobsCount}" -gt 0 ] && Console::end "[INSTALLED]" && return "${TRUE}" || return "${FALSE}"
}

Service::Scheduler::pause() {
    Compose::command pause scheduler 2>/dev/null || true
}

Service::Scheduler::unpause() {
    Compose::command unpause scheduler 2>/dev/null || true
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
    [ "${SPRYKER_TESTING_ENABLE}" -eq 1 ] && return "${TRUE}"

    Runtime::waitFor scheduler

    for region in "${SPRYKER_STORES[@]}"; do
        eval "${region}"
        for store in "${STORES[@]}"; do
            SPRYKER_CURRENT_STORE="${store}"
            Console::info "${2} scheduler jobs for ${SPRYKER_CURRENT_STORE} store."
            Compose::exec "vendor/bin/install -r docker -s scheduler-${1}"
        done
    done
}
