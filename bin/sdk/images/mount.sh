#!/bin/bash

import sdk/images/common.sh

function Images::build() {
    for arg in "${@}"; do
        case "${arg}" in
            '--force')
                # it is always it.
                ;;
            '--no-cache')
                # TODO implement --no-cache for build images
                ;;
            *)
                Console::verbose "\nUnknown option ${INFO}${arg}${WARN} is acquired for Images::build."
                ;;
        esac
    done

    Images::buildApp mount
    Images::buildCli mount
    Images::tagAll "${SPRYKER_DOCKER_TAG}"
}
