#!/bin/bash

Registry::addCommand "run" "Command::run"
Registry::addCommand "start" "Command::run"

Registry::Help::command -c "run | start" "Runs Spryker containers."

function Command::run() {
    Compose::run
    Compose::command restart frontend gateway

    Runtime::waitFor ${SPRYKER_INTERNAL_PROJECT_NAME}_database
    Runtime::waitFor ${SPRYKER_INTERNAL_PROJECT_NAME}_search
    Runtime::waitFor ${SPRYKER_INTERNAL_PROJECT_NAME}_key_value_store

    return "${TRUE}"
}
