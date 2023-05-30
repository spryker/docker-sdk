#!/bin/bash

set -e

pushd "${BASH_SOURCE%/*}" >/dev/null
. console.sh
popd >/dev/null

IS_TERMINAL=$(tty >/dev/null && [ -z "${COMMAND}" ] && echo '1' || echo '')

# shellcheck disable=SC1090
function importEnvFiles() {
    set -a
    if [ -n "${SPRYKER_TESTING_ENABLE_FOR_CLI}" ]; then
        source "${HOME}/env/testing.env"
    fi
    source "$(getEnvFile)"
    if [ -n "${SPRYKER_TESTING_ENABLE_FOR_CLI}" ]; then
        source "${HOME}/env/testing.env"
    fi
    # Alternatively we can copy env and source it again
    set +a

    export SPRYKER_LOG_STDOUT=/tmp/stdout
    export SPRYKER_LOG_STDERR=/tmp/stderr
}

function printLogo() {
    if [ -n "${IS_TERMINAL}" ]; then
        bash logo/spryker-cli.sh
    fi
}

function getEnvFile() {
    echo "${HOME}/env/$(echo "${APPLICATION_STORE:-$SPRYKER_CURRENT_REGION}" | tr '[:upper:]' '[:lower:]').env"
}

function setPrompt() {
    local status=""
    if [ -n "${SPRYKER_CURRENT_REGION}" ]
    then
        status+="${YELLOW}Region${NC}: ${GREEN}${SPRYKER_CURRENT_REGION}${NC}"
    fi
    if [ -n "${APPLICATION_STORE}" ]
    then
        status+="${YELLOW}Store${NC}: ${GREEN}${APPLICATION_STORE}${NC}"
    fi
    status+=" | ${YELLOW}Env${NC}: ${GREEN}${APPLICATION_ENV}${NC}"
    if [ -n "${SPRYKER_XDEBUG_MODE_ENABLE}" ]; then
        status+=" | ${PLUM}Debug${NC}: ($([ -n "${SPRYKER_XDEBUG_ENABLE_FOR_CLI}" ] && echo "${GREEN}X" || echo "${DGRAY}.")${NC})"
    fi
    status+=" | ${PLUM}Testing${NC}: ($([ -n "${SPRYKER_TESTING_ENABLE_FOR_CLI}" ] && echo "${GREEN}X" || echo "${DGRAY}.")${NC})"

    export PS1="╭─${CYAN}\w${NC} | ${status}\n╰─$ "
}

pushd "${BASH_SOURCE%/*}" >/dev/null

importEnvFiles
printLogo
setPrompt

popd >/dev/null

if [ -n "${SPRYKER_XDEBUG_ENABLE_FOR_CLI}" ] && [ -n "${SPRYKER_XDEBUG_MODE_ENABLE}" ]; then
    export PHP_INI_SCAN_DIR=:/usr/local/etc/php/debug.conf.d
fi

# --------------------------
if [ -z "${COMMAND}" ]; then
    bash --norc
else
    bash --norc -c "${COMMAND}"
fi
