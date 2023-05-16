#!/bin/bash

Registry::addCommand "run" "Command::run"
Registry::addCommand "start" "Command::run"

Registry::Help::command -c "run | start" "Runs Spryker containers."

function Command::run() {
    Compose::run --profile ${SPRYKER_PROJECT_NAME}
    Compose::command --profile ${SPRYKER_PROJECT_NAME} --profile ${SPRYKER_INTERNAL_PROJECT_NAME} restart ${SPRYKER_PROJECT_NAME}_frontend ${SPRYKER_INTERNAL_PROJECT_NAME}_gateway

    Runtime::waitFor ${SPRYKER_INTERNAL_PROJECT_NAME}_database
    Runtime::waitFor ${SPRYKER_INTERNAL_PROJECT_NAME}_search
    Runtime::waitFor ${SPRYKER_INTERNAL_PROJECT_NAME}_key_value_store

    return "${TRUE}"
}
