#!/bin/bash

import project/bootstrap.sh
import project/hooks.sh
import project/validator.sh

function Project::getNameFromPath() {
  basename "${1}"
}

function Project::info() {
  Console::info "Project name: ${SPRYKER_PROJECT_NAME}\nProject path: ${SPRYKER_PROJECT_PATH}\n"
}

function Project::getListOfEnabledProjects() {
  local enabledPaths=($(find ${DEPLOYMENT_DIR}/.. -type f -iname ${ENABLED_FILENAME}))
  declare -a profiles

  for i in "${enabledPaths[@]}" ; do
    local projectName=$(basename $(dirname "${i}"))

    profiles+=(${projectName})
  done

  echo "${profiles[*]}"
}

function Project::getProjectList() {
  local paths=($(ls -d ${DEPLOYMENT_DIR}/../*))
  declare -a projects
  declare -a uniqProjects

  for i in "${paths[@]}" ; do
    local projectName=$(basename "${i}")

    if [ "${projectName}" = ${SPRYKER_INTERNAL_PROJECT_NAME} ]; then
        continue
    fi

    projects+=(${projectName})
  done

  uniqProjects=($(for project in "${projects[@]}"; do echo "${project}"; done | sort -u))

  echo "${uniqProjects[*]}"
}
