#!/bin/bash

Registry::addCommand "sync" "Command::sync"

function Command::sync() {

    local command=${1}
    shift || true

    case ${command} in
        ''|start)
            sync create
            sync start
            ;;
        logs|log)
            sync logs # TODO deprecated, use Mount::logs instead
            Mount::logs "${@}"
            ;;
        *)
            Console::error "Unknown command ${INFO}${command}${WARN} is occurred."
            exit 1
            ;;
    esac

    return "${TRUE}"
}
