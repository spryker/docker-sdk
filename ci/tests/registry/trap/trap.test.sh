#!/bin/bash

set -a

source bin/standalone/console.sh

exitCode=0

function assert() {
    local script=$1
    local expected=$2
    local result

    Console::start "${GREEN}${script}${NC}"

    result=$(bash "${BASH_SOURCE%/*}/${script}")

    if [ "${result}" != "${expected}" ]; then
        Console::error "TEST FAIL: '${script}'. Expected: '${expected}'. Actual: '${result}'";
        exitCode=1

        return 0
    fi

    Console::end "[OK]"
}

assert check-on-exit.case.sh "1. ON-EXIT 1. ON-EXIT 2. ON-EXIT"
assert check-release.case.sh "1. RELEASED 1. RELEASED 2. ON-EXIT"
assert chech-remove.case.sh ""
assert check-edge.case.sh ""

exit "${exitCode}"
