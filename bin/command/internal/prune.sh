#!/bin/bash

Registry::addCommand "prune" "Command::prune"

function Command::prune() {
	local forceArg=${1}

	if [ "${forceArg}" == "--f" ]; then
		forceArg='-f'
	else
		forceArg=''
	fi

    Compose::down
    sync clean # TODO deprecated, use Registry::Flow::addAfterDown in mounts
    Console::error "This will delete ALL docker images and volumes on the host."
    docker image prune ${forceArg}
    docker volume prune ${forceArg}
    docker system prune -a ${forceArg}
    docker builder prune -a ${forceArg}

    return "${TRUE}"
}
