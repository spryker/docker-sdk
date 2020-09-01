#!/bin/bash

source bin/framework.sh

function trap1() {
    echo -n "1. ON-EXIT "
}

function trap2() {
    echo -n "2. ON-EXIT"
}

function trap3() {
    echo -n "3. DELETED "
}

Registry::Trap::addExitHook '1. ON-EXIT' trap1
Registry::Trap::addExitHook '1. ON-EXIT' trap1 # Second declaration
Registry::Trap::addExitHook on-exit2 trap2
Registry::Trap::addExitHook to-delete trap3

Registry::Trap::removeExitHook to-delete

exit 0
