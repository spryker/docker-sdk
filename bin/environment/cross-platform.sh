#!/bin/bash

function Environment::crossPlatform() {
    export XARGS_NO_RUN_IF_EMPTY=$(echo '' | xargs echo "--no-run-if-empty")
}

Registry::addChecker 'Environment::crossPlatform'
