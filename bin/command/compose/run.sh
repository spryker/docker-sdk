#!/bin/bash

Registry::addCommand "run" "Command::run"
Registry::addCommand "start" "Command::run"

Registry::Help::command -c "run | start" "Runs Spryker containers."

function Command::run() {
    Compose::run
    if [ "${SPRYKER_TRAEFIK_IS_ENABLED}" == "1"]; then
        Compose::command restart frontend
    else
        Compose::command restart frontend gateway
    fi

    Runtime::waitFor database
    Runtime::waitFor search
    Runtime::waitFor key_value_store

    return "${TRUE}"
}
