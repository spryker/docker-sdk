#!/bin/bash

source bin/framework.sh

function trap1() {
    echo -n "1. DELETED "
}

function trap2() {
    echo -n "2. DELETED "
}

Registry::Trap::addExitHook '1. DELETED'
Registry::Trap::addExitHook delete2

Registry::Trap::removeExitHook delete2
Registry::Trap::removeExitHook '1. DELETED'

exit 0
