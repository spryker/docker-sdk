#!/bin/bash

require docker

function sync() {

    case $1 in
        logs)
            while :; do
                curl -X GET --unix-socket ~/Library/Containers/com.docker.docker/Data/docker-api.sock http:/localhost/synchronize/state
                sleep 1
            done
            ;;
    esac

    return "${TRUE}"
}

function Sync::Delegated::checkCompatibility() {

    Console::verbose::start "Checking mount compatibility..."

    if [ "$(Platform::getPlatform)" != 'macos' ]; then
        Console::error "Delegated mount type is available only on MacOS. Please, change the mount type in deploy.yml."
        exit 1
    fi

    if ! (command -v docker >/dev/null && docker >/dev/null 2>&1); then
        Console::error "Docker is not running. Please, make sure Docker is installed and running."
        exit 1
    fi

    if ! curl -X GET -f -I --unix-socket ~/Library/Containers/com.docker.docker/Data/docker-api.sock http:/localhost/synchronize/state >/dev/null 2>&1; then
        Console::error "Your version of Docker Desktop does not support syncronization (https://docs.docker.com/docker-for-mac/mutagen). Please, update Docker or change the mount type in deploy.yml."
        exit 1
    fi

    Console::end "[OK]"
}

Registry::addChecker 'Sync::Delegated::checkCompatibility'
