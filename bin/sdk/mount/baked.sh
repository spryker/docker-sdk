#!/bin/bash

function sync() {

    case $1 in
        logs)
            Console::error "This mount mode does not support logging."
            exit 1
            ;;
    esac

    return "${TRUE}"
}
