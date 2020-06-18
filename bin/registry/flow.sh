#!/bin/bash

declare -a FLOW_BOOT
declare -a FLOW_BEFORE_RUN
declare -a FLOW_AFTER_DOWN

function Registry::Flow::addBoot() {
    local func=$1

    FLOW_BOOT+=("${func}")

    return "${TRUE}"
}

function Registry::Flow::runBoot() {

    local func=''

    for func in "${FLOW_BOOT[@]}"; do
        ${func} "${@}"
    done

    return "${TRUE}"
}

function Registry::Flow::addBeforeRun() {
    local func=$1

    FLOW_BEFORE_RUN+=("${func}")

    return "${TRUE}"
}

function Registry::Flow::runBeforeRun() {

    local func=''

    for func in "${FLOW_BEFORE_RUN[@]}"; do
        ${func} "${@}"
    done

    return "${TRUE}"
}

function Registry::Flow::addAfterDown() {
    local func=$1

    FLOW_AFTER_DOWN+=("${func}")

    return "${TRUE}"
}

function Registry::Flow::runAfterDown() {

    local func=''

    for func in "${FLOW_AFTER_DOWN[@]}"; do
        ${func} "${@}"
    done

    return "${TRUE}"
}
