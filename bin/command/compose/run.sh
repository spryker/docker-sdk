#!/bin/bash

Registry::addCommand "run" "Command::run"
Registry::addCommand "start" "Command::run"

Registry::Help::command -c "run | start" "Runs Spryker containers."

function Command::run() {
    Compose::run
    Compose::command restart frontend gateway

    Runtime::waitFor database
    Runtime::waitFor search
    Runtime::waitFor key_value_store

    return "${TRUE}"
}
