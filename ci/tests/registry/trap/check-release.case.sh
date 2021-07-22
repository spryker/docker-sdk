#!/bin/bash

source bin/framework.sh

function trap1() {
    echo -n "1. RELEASED "
}

function trap2() {
    echo -n "2. ON-EXIT"
}

Registry::Trap::addExitHook '2. ON-EXIT' trap2
Registry::Trap::addExitHook '1. RELEASED' trap1
Registry::Trap::addExitHook '1. RELEASED' trap1 # Second declaration

Registry::Trap::releaseExitHook '1. RELEASED'

exit 0
