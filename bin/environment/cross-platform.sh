#!/bin/bash

function Environment::crossPlatform() {
    local XARGS_NO_RUN_IF_EMPTY=$(echo '' | xargs echo "--no-run-if-empty")
    # shellcheck disable=SC2139
    alias xargs="xargs ${XARGS_NO_RUN_IF_EMPTY}"
}

Registry::addChecker 'Environment::crossPlatform'
