#!/bin/bash

function Service::Scheduler::isInstalled() {
   true
}

Service::Scheduler::pause() {
  Service::Scheduler::_run suspend "Suspending"
}

Service::Scheduler::unpause() {
  Service::Scheduler::_run resume "Resuming"
}

function Service::Scheduler::start() {
   Service::Scheduler::isInstalled

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
   true
}

function Service::Scheduler::_run() {
   [ ! -z "${SPRYKER_TESTING_ENABLE}" ] && [ "${SPRYKER_TESTING_ENABLE}" -eq "1" ] && return "${TRUE}"

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
