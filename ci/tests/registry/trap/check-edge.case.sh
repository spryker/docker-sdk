#!/bin/bash

source bin/framework.sh

function trap1() {
    echo -n "1. DELETED "
}

function trap2() {
    echo -n "2. EMPTY"
}

function trap3() {
    echo -n "3. EMPTY"
}

Registry::Trap::addExitHook '' trap2
Registry::Trap::addExitHook '' trap3
Registry::Trap::addExitHook to-delete trap1
Registry::Trap::addExitHook to-delete trap2

Registry::Trap::removeExitHook to-delete
Registry::Trap::releaseExitHook ''

exit 0
