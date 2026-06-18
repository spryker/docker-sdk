#!/usr/bin/env bash

import sdk/images/common.sh

# When SPRYKER_DOCKER_REUSE_IMAGES is set, the caller has already pulled the
# prebuilt baked runtime images from a registry and tagged them with the local
# names below. In that case we skip the (expensive) in-place image build and let
# `up`/`start` run the pulled images directly. Build-once, run-many.
function Images::_imageExists() {
    docker image inspect "${1}" >/dev/null 2>&1
}

function Images::_reuseImages() {
    [ -n "${SPRYKER_DOCKER_REUSE_IMAGES}" ]
}

function Images::buildApplication() {
    for arg in "${@}"; do
        case "${arg}" in
            '--force')
                # it is always it.
                ;;
            '--no-cache')
                # TODO implement --no-cache for build images
                ;;
            *)
                Console::verbose "\nUnknown option ${INFO}${arg}${WARN} is acquired for Images::buildApplication."
                ;;
        esac
    done

    if Images::_reuseImages \
        && Images::_imageExists "${SPRYKER_DOCKER_PREFIX}_run_app:${SPRYKER_DOCKER_TAG}" \
        && Images::_imageExists "${SPRYKER_DOCKER_PREFIX}_run_cli:${SPRYKER_DOCKER_TAG}"; then
        Console::verbose "${INFO}Reusing prebuilt application images (SPRYKER_DOCKER_REUSE_IMAGES set)${NC}"
        return "${TRUE}"
    fi

    Images::_buildApp baked
    Images::tagApplications "${SPRYKER_DOCKER_TAG}"
}

function Images::buildFrontend() {
    for arg in "${@}"; do
        case "${arg}" in
            '--force')
                # it is always it.
                ;;
            '--no-cache')
                # TODO implement --no-cache for build images
                ;;
            *)
                Console::verbose "\nUnknown option ${INFO}${arg}${WARN} is acquired for Images::buildFrontend."
                ;;
        esac
    done

    if Images::_reuseImages \
        && Images::_imageExists "${SPRYKER_DOCKER_PREFIX}_run_frontend:${SPRYKER_DOCKER_TAG}" \
        && Images::_imageExists "${SPRYKER_DOCKER_PREFIX}_gateway:${SPRYKER_DOCKER_TAG}"; then
        Console::verbose "${INFO}Reusing prebuilt frontend/gateway images (SPRYKER_DOCKER_REUSE_IMAGES set)${NC}"
        return "${TRUE}"
    fi

    Images::_buildFrontend baked
    Images::_buildGateway
    Images::tagFrontend "${SPRYKER_DOCKER_TAG}"
}
