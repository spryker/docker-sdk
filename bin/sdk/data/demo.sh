#!/bin/bash

function Data::isLoaded() {
    Console::start "Checking is demo data loaded for ${SPRYKER_CURRENT_REGION}... "
    Database::haveTables && Console::end "[LOADED]" && return "${TRUE}" || return "${FALSE}"
}

function Data::load() {
    local brokerInstalled=""
    local schedulerSuspended=""
    local verboseOption=$([ "${VERBOSE}" == "1" ] && echo -n " -vvv" || echo -n '')

    Runtime::waitFor database
    Runtime::waitFor broker
    Runtime::waitFor search
    Runtime::waitFor key_value_store

    local force=''
    if [ "$1" == '--force' ]; then
        force=1
        shift || true
    fi

    for regionData in "${SPRYKER_STORES[@]}"; do
        eval "${regionData}"

        # shellcheck disable=SC2034
        SPRYKER_CURRENT_REGION="${REGION}"
        SPRYKER_CURRENT_STORE="${STORES[0]}"

        if [ -z "${force}" ] && Data::isLoaded; then
            continue
        fi

        if [ -z "${brokerInstalled}" ]; then
            Service::Broker::install
            brokerInstalled=1
        fi

        if [ -z "${schedulerSuspended}" ]; then
            schedulerSuspended=1
            Service::Scheduler::pause
            Registry::Trap::addExitHook 'resumeScheduler' 'Service::Scheduler::unpause'
        fi

        Console::info "Loading demo data for ${SPRYKER_CURRENT_REGION} region."
        Compose::exec "vendor/bin/install${verboseOption} -r ${SPRYKER_PIPELINE} -s clean-storage -s init-storage"
        Database::init

        for store in "${STORES[@]}"; do
            SPRYKER_CURRENT_STORE="${store}"
            Console::info "Init storages for ${SPRYKER_CURRENT_STORE} store."
            Compose::exec "vendor/bin/install${verboseOption} -r ${SPRYKER_PIPELINE} -s init-storages-per-store"
        done

        SPRYKER_CURRENT_STORE="${STORES[0]}"
        local demoDataSection=${1:-demodata}
        Compose::exec "vendor/bin/install${verboseOption} -r ${SPRYKER_PIPELINE} -s init-storages-per-region -s ${demoDataSection}"
    done

    Registry::Trap::releaseExitHook 'resumeScheduler'
}
