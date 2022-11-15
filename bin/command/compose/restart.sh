#!/bin/bash

Registry::addCommand "restart" "Command::restart"

Registry::Help::command -c "restart" "Restarts Spryker containers."

function Command::restart() {
    Compose::restart
    Runtime::waitFor ${SPRYKER_INTERNAL_PROJECT_NAME}_database
    Runtime::waitFor ${SPRYKER_INTERNAL_PROJECT_NAME}_search
    Runtime::waitFor ${SPRYKER_INTERNAL_PROJECT_NAME}_key_value_store

    return "${TRUE}"
}
