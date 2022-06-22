#!/bin/bash

Registry::addCommand "generate-env" "Command::generate-env"

Registry::Help::command -c "generate-env" "Generate \`.env.docker.local file\` based on deploy file."

function Command::generate-env() {
    if [ -f "${DEPLOYMENT_DIR}/.env.docker.local" ]; then
        cp "${DEPLOYMENT_DIR}/.env.docker.local" "${PROJECT_DIR}/.env.docker.local"
    else
      Console::error "${WARN}Need to run \`docker/sdk boot\` first.${NC}"
    fi

    if [ -f "${DEPLOYMENT_DIR}/.gitignore" ]; then
        cp "${DEPLOYMENT_DIR}/.gitignore" "${PROJECT_DIR}/.gitignore"
    else
      Console::error "${WARN}Need to run \`docker/sdk boot\` first.${NC}"
    fi
}
