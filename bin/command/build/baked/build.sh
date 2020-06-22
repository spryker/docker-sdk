#!/bin/bash

Registry::addCommand "build" "Command::build"

Registry::Help::command -c "build" "[Deprecated for non-dev mode] Builds images, codebase and assets."
Registry::Help::command -c "build images" "[Deprecated for non-dev mode] Builds images and codebase."
Registry::Help::command -c "build assets" "[Deprecated for non-dev mode] Builds assets."

function Command::build() {

    Console::warn 'This command is deprecated for baked mount mode. Please, use up or export commands as well.'

    subCommand=${1}
    case ${subCommand} in
        images | image)
            Images::build --force
            ;;
        assets | asset)
            Assets::build --force
            ;;
        '')
            Images::build --force
            Assets::build --force
            ;;
        *)
            Console::error "Unknown build target '${subCommand}' is occurred. No action." > /dev/stderr
            exit 1
            ;;
    esac

    return "${TRUE}"
}
