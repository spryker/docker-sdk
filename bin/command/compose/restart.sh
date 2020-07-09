#!/bin/bash

Registry::addCommand "restart" "Command::restart"

Registry::Help::command -c "restart" "Restarts Spryker containers."

function Command::restart() {
    Compose::restart
    Runtime::waitFor database
    Runtime::waitFor search
    Runtime::waitFor key_value_store

    return "${TRUE}"
}
