#!/bin/bash

Registry::addCommand "build" "Command::build"

Registry::Help::command -c "build" "Builds images, codebase and assets."
Registry::Help::command -c "build images" "Builds images and codebase."
Registry::Help::command -c "build codebase" "Builds codebase."
Registry::Help::command -c "build assets" "Builds assets."

function Command::build() {
    subCommand=${1}
    case ${subCommand} in
        images | image)
            Images::build --force
            # Codebase building is deprecated here. It is left for BC reasons.
            Codebase::build --force
            ;;
        codebase | code)
            Codebase::build --force
            ;;
        assets | asset)
            Assets::build --force
            ;;
        '')
            Images::build --force
            Codebase::build --force
            Assets::build --force
            ;;
        *)
            Console::error "Unknown build target '${subCommand}' is occurred. No action." > /dev/stderr
            exit 1
            ;;
    esac

    return "${TRUE}"
}
