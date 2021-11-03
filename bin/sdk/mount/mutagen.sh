#!/bin/bash

require docker grep awk

import lib/version.sh
import lib/string.sh

# shellcheck disable=SC2034
DOCKER_COMPOSE_SUBSTITUTE='mutagen compose'

function Mount::logs() {
    mutagen sync monitor "${SPRYKER_SYNC_SESSION_NAME}"
}

function sync() {
    # @deprecated

    return "${TRUE}"
}

function Mount::Mutagen::beforeUp() {
    local sessionStatus

    # Let's clean volume on cold start when containers are not running to avoid offline conflicts
    # The volume will not be deleted if any app container is running.
    docker volume rm "${SPRYKER_SYNC_VOLUME}" >/dev/null 2>&1 || true

    terminateMutagenSessionsWithObsoleteDockerId

    # Clean content of the sync volume if the sync session is terminated or halted.
    sessionStatus=$(mutagen sync list "${SPRYKER_SYNC_SESSION_NAME}" 2>/dev/null | grep 'Status:' | awk '{print $2}' || echo '')
    if [ -z "${sessionStatus}" ] || [ "${sessionStatus}" == 'Halted' ]; then
        Console::verbose::start "${INFO}Cleaning previous synced files${NC}"
        mutagen sync terminate "${SPRYKER_SYNC_SESSION_NAME}" >/dev/null 2>&1 || true
        docker run -i --rm -v "${SPRYKER_SYNC_VOLUME}:/data" busybox find /data/ ! -path /data/ -delete >/dev/null 2>&1 || true
        Console::end "[OK]"
    fi
}

function terminateMutagenSessionsWithObsoleteDockerId() {
    dockerId=$(docker info --format '{{.ID}}' 2>/dev/null | awk '{ gsub(":","_",$1); print $1 }' || echo '')

    if [ -z "$dockerId" ]; then
        Console::error "${WARN}Docker ID is empty, please check the script and try again."
        return
    fi

    Console::log "Checking mutagen sessions for docker ID: ${dockerId}"

    sessionIds=$(mutagen sync list "${SPRYKER_SYNC_SESSION_NAME}" 2>/dev/null | grep 'Identifier:' | awk '{print $2}' || echo '')

    for sessionId in ${sessionIds}; do
        if [ -z "$sessionId" ]; then
            Console::warn "Session ID is empty, please check the script and try again."
            continue
        fi

        sessionDockerId=$(mutagen sync list "${sessionId}" 2>/dev/null | grep 'io.mutagen.compose.daemon.identifier:' | awk '{print $2}' || echo '')

        if [ -z "$sessionDockerId" ]; then
           Console::warn "Docker ID for session ${sessionId} is empty, please check the script and try again."
            continue
        fi

        if [ "$sessionDockerId" != "$dockerId" ]; then
            mutagen sync terminate "${sessionId}"
            Console::log "Mutagen session ${sessionId} has been terminated."
        fi
    done
}

# This is necessary due to https://github.com/mutagen-io/mutagen/issues/224
function Mount::Mutagen::beforeRun() {
    Console::verbose::start "${INFO}Creating file syncronization volume${NC}"
    docker volume create --name="${SPRYKER_SYNC_VOLUME}" >/dev/null
    docker run -it --rm -v "${SPRYKER_SYNC_VOLUME}:/data" busybox chmod 777 /data >/dev/null 2>&1
    Console::end "[OK]"
}

# This is necessary due to https://github.com/mutagen-io/mutagen/issues/225
function Mount::Mutagen::afterCliReady() {
    Console::verbose "${INFO}Flushing file syncronization${NC}"
    mutagen sync flush "${SPRYKER_SYNC_SESSION_NAME}"
}

function Mount::Mutagen::afterDown() {
    Console::verbose "${INFO}Pruning file syncronization${NC}"
    docker volume rm "${SPRYKER_SYNC_VOLUME}" >/dev/null 2>&1 || true
    mutagen sync terminate "${SPRYKER_SYNC_SESSION_NAME}" >/dev/null 2>&1 || true
}

function Mount::Mutagen::install() {

    local installedVersion
    local requiredMinimalVersion='0.12.0'

    installedVersion=$(String::trimWhitespaces "$(
        command -v mutagen >/dev/null 2>&1
        # shellcheck disable=SC2015
        test $? -eq 0 && mutagen version
    )")

    if [ -z "${installedVersion}" ]; then
        Console::error "Mutagen.io binary is not available. Please, install Mutagen.io. Minimum required version is: ${requiredMinimalVersion}."

        if [ "${_PLATFORM}" == 'macos' ]; then
            echo -n "brew install mutagen-io/mutagen/mutagen-beta"
        fi

        return "${FALSE}"
    fi

    if [ "$(Version::parse "${installedVersion}")" -lt "$(Version::parse "${requiredMinimalVersion}")" ]; then
        Console::error "Mutagen.io version ${installedVersion} is not supported. Please, update Mutagen.io to at least ${requiredMinimalVersion}."

        if [ "${_PLATFORM}" == 'macos' ]; then
            echo -n "brew list | grep mutagen | xargs ${XARGS_NO_RUN_IF_EMPTY} brew remove && brew install mutagen-io/mutagen/mutagen-beta"
        fi
        return "${FALSE}"
    fi

    return "${TRUE}"
}

Registry::Flow::addBeforeUp 'Mount::Mutagen::beforeUp'
Registry::Flow::addBeforeRun 'Mount::Mutagen::beforeRun'
Registry::Flow::addAfterCliReady 'Mount::Mutagen::afterCliReady'
Registry::Flow::addAfterDown 'Mount::Mutagen::afterDown'
Registry::addInstaller 'Mount::Mutagen::install'
