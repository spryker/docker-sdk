#!/bin/bash

Registry::addCommand "list-env" "Command::list-env"

Registry::Help::command -c "list-env" "Print env variables based on deploy file(environment-configuration section)."

function Command::list-env() {
    if [ -f "${DEPLOYMENT_DIR}/.env.docker.list" ]; then
        cat "${DEPLOYMENT_DIR}/.env.docker.list"
    else
      Console::error "${WARN}Need to run \`docker/sdk boot\` first.${NC}"
    fi
}
