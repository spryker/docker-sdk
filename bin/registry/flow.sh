#!/bin/bash

declare -a FLOW_BOOT
declare -a FLOW_BEFORE_UP
declare -a FLOW_BEFORE_RUN
declare -a FLOW_AFTER_CLI_READY
declare -a FLOW_AFTER_RUN
declare -a FLOW_AFTER_UP
declare -a FLOW_AFTER_STOP
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

function Registry::Flow::addBeforeUp() {
    local func=$1

    FLOW_BEFORE_UP+=("${func}")

    return "${TRUE}"
}

function Registry::Flow::runBeforeUp() {

    local func=''

    for func in "${FLOW_BEFORE_UP[@]}"; do
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

function Registry::Flow::addAfterRun() {
    local func=$1

    FLOW_AFTER_RUN+=("${func}")

    return "${TRUE}"
}

function Registry::Flow::runAfterRun() {

    local func=''

    for func in "${FLOW_AFTER_RUN[@]}"; do
        ${func} "${@}"
    done

    return "${TRUE}"
}

function Registry::Flow::addAfterCliReady() {
    local func=$1

    FLOW_AFTER_CLI_READY+=("${func}")

    return "${TRUE}"
}

function Registry::Flow::runAfterCliReady() {

    local func=''

    for func in "${FLOW_AFTER_CLI_READY[@]}"; do
        ${func} "${@}"
    done

    return "${TRUE}"
}

function Registry::Flow::addAfterUp() {
    local func=$1

    FLOW_AFTER_UP+=("${func}")

    return "${TRUE}"
}

function Registry::Flow::runAfterUp() {

    local func=''

    for func in "${FLOW_AFTER_UP[@]}"; do
        ${func} "${@}"
    done

    return "${TRUE}"
}

function Registry::Flow::addAfterStop() {
    local func=$1

    FLOW_AFTER_STOP+=("${func}")

    return "${TRUE}"
}

function Registry::Flow::runAfterStop() {

    local func=''

    for func in "${FLOW_AFTER_STOP[@]}"; do
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
