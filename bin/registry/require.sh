#!/bin/bash

declare -a REQUIRE_CHECKERS
declare -a REQUIRE_BINARIES

function Registry::require() {

    for binary in "${@}"; do
        REQUIRE_BINARIES+=("${binary}")
    done

    return "${TRUE}"
}

function Registry::requireLinux() {
    [ "${_PLATFORM}" == 'linux' ] && Registry::require "${@}"

    return "${TRUE}"
}

function Registry::requireMacos() {
    [ "${_PLATFORM}" == 'macos' ] && Registry::require "${@}"

    return "${TRUE}"
}

function Registry::requireWindows() {
    [ "${_PLATFORM}" == 'windows' ] && Registry::require "${@}"

    return "${TRUE}"
}

function Registry::addChecker() {
    local func=$1

    REQUIRE_CHECKERS+=("${func}")

    return "${TRUE}"
}

function Registry::checkRequirements() {

    Console::verbose::start "Checking requirements..."

    local func=''
    local binary=''

    for binary in "${REQUIRE_BINARIES[@]}"; do
        case ${binary} in
            "-"*)
                # skipping arguments started with '-'
                continue
                ;;
        esac

        local binPath=$(command -v "${binary}" || true)

        if [ -z "${binPath}" ]; then
            Console::error "'${binary}' is not found. Please, make sure this application is installed and added to PATH."
            exit 1
        fi
    done

    Console::end "[OK]"

    for func in "${REQUIRE_CHECKERS[@]}"; do
        ${func} "${@}"
    done

    return "${TRUE}"
}
