#!/bin/bash

function Bool::normalizeBashBool() {
    case "${1}" in
        ${TRUE})
            echo -n 1
            ;;
        ${FALSE})
            echo -n 0
            ;;
        *)
            Console::error "Unknown boolean value \"${1}\". Use \${TRUE} or \${FALSE}."
            ;;
    esac
}
