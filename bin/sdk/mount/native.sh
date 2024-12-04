#!/usr/bin/env bash

function Mount::logs() {
    Console::error "This mount mode does not support logging."
    exit 1
}

function sync() {
    # @deprecated

    return "${TRUE}"
}
