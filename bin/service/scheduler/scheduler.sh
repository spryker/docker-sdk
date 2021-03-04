#!/bin/bash

function Service::Scheduler::isInstalled() {
   true
}

Service::Scheduler::pause() {
   [ ! -z "${SPRYKER_TESTING_ENABLE}" ] && [ "${SPRYKER_TESTING_ENABLE}" -eq "1" ] && return "${TRUE}"

   Runtime::waitFor scheduler
   Console::start -n "Suspending scheduler..."

   local masterStateUri="/api/app/update_master_state"

   for scheduler in "${SPRYKER_AVAILABLE_SCHEDULERS[@]}"; do
     eval "${scheduler}"

     local response=$(Compose::exec 'curl -sL -X POST '${BASE_URL}${masterStateUri}' --header "X-API-Key: '${API_KEY}'" --header "Content-Type: application/json" --data "{\"enabled\": 0}"' | jq .code)
     [ "${response}" -gt 0 ] && return "${FALSE}"
   done

   local counter=1
   local interval=2
   local waitFor=60

   local jobsActiveUri="/api/app/get_active_jobs/v1"

   for scheduler in "${SPRYKER_AVAILABLE_SCHEDULERS[@]}"; do
      eval "${scheduler}"

      local runningJobsCount=$(Compose::exec 'curl -sL '${BASE_URL}${jobsActiveUri}' --header "X-API-Key: '${API_KEY}'" | jq -r '.jobs' | jq length')

      [ "${runningJobsCount}" -eq "0" ] && break
      [ "${counter}" -ge "${waitFor}" ] && break
      counter=$((counter + interval))
      sleep "${interval}"
   done

   Console::end "[DONE]"
}

Service::Scheduler::unpause() {
   [ ! -z "${SPRYKER_TESTING_ENABLE}" ] && [ "${SPRYKER_TESTING_ENABLE}" -eq "1" ] && return "${TRUE}"

   Runtime::waitFor scheduler
   Console::start -n "Resuming scheduler..."

   local masterStateUri="/api/app/update_master_state"

   for scheduler in "${SPRYKER_AVAILABLE_SCHEDULERS[@]}"; do
     eval "${scheduler}"
     local response=$(Compose::exec 'curl -sL -X POST '${BASE_URL}${masterStateUri}' --header "X-API-Key: '${API_KEY}'" --header "Content-Type: application/json" --data "{\"enabled\": 1}"' | jq .code)
     [ "${response}" -gt 0 ] && return "${FALSE}"
   done

   Compose::exec 'curl -sLI -X POST ${SPRYKER_SCHEDULER_HOST}:${SPRYKER_SCHEDULER_PORT}/cancelQuietDown' >/dev/null || true
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
