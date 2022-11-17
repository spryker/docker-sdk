#!/bin/bash

Registry::addCommand "prune" "Command::prune"

function Command::prune() {
	local forceArg=${1}

	if [ "${forceArg}" == "--f" ]; then
		forceArg='-f'
	else
		forceArg=''
	fi

  Compose::command down
  sync clean # TODO deprecated, use Registry::Flow::addAfterDown in mounts
  Console::error "This will delete ALL docker images and volumes on the host."

  docker volume prune ${forceArg}
  dropImages ${forceArg}
#  docker system prune -a ${forceArg}
  docker builder prune -a ${forceArg}

  return "${TRUE}"
}

function dropImages() {
  local forceArg=${1}
  local projects=($(Project::getProjectList))

  for projectName in "${projects[@]}" ; do
    local imageIdList=($(docker images "${projectName}_*" --format "{{.ID}}"))

    if [ -z "${imageIdList[*]}" ]; then
      continue
    fi

    local uniqImageIdList=($(for imageId in "${imageIdList[@]}"; do echo "${imageId}"; done | sort -u))

    docker image rm ${uniqImageIdList[*]} ${forceArg}
  done

  local nonameImageIdList=($(docker images -f 'dangling=true' -q))

  if [ -n "${nonameImageIdList[*]}" ]; then
    local uniqImageIdList=($(for imageId in "${nonameImageIdList[@]}"; do echo "${imageId}"; done | sort -u))
    docker image rm ${uniqImageIdList[*]} ${forceArg}
  fi

  docker images --filter "reference=spryker_docker_sdk" --format "{{.ID}}" | xargs ${XARGS_NO_RUN_IF_EMPTY} docker rmi -f
}
