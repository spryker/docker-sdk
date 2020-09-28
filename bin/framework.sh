#!/bin/bash

set -e
shopt -s extglob expand_aliases

pushd "${BASH_SOURCE%/*}" >/dev/null
FRAMEWORK_CWD=$(pwd)

. ./standalone/constants.sh
. ./standalone/console.sh

. ./lib/string.sh

. ./platform.sh

. ./registry/require.sh
. ./registry/trap.sh
. ./registry/command.sh
. ./registry/help.sh
. ./registry/installer.sh
. ./registry/flow.sh

popd >/dev/null

SYSTEM_IMPORT_LIST=""

function System::Bootstrap() {
    Registry::checkRequirements "${@}"
}

function System::import() {
    local dependency=${1##+(.|/)}
    shift || true

    # shellcheck disable=SC1090
    if [[ "${SYSTEM_IMPORT_LIST}" != *";${dependency};"* ]]; then
        SYSTEM_IMPORT_LIST="${SYSTEM_IMPORT_LIST};${dependency};"
        source "${FRAMEWORK_CWD}/${dependency}" "${@}"
    fi
}

alias require="Registry::require"
alias require:linux="Registry::requireLinux"
alias require:macos="Registry::requireMacos"
alias require:windows="Registry::requireWindows"
alias import="System::import"
