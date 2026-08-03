#!/bin/bash

function Mutagen::getInstalledVersion() {
    if ! command -v mutagen >/dev/null 2>&1; then
        return 1
    fi
    
    String::trimWhitespaces "$(mutagen version 2>/dev/null || echo '')"
}

function Environment::checkMutagenVersion() {
    if [[ "${_PLATFORM}" != "macos" ]]; then
        return 0
    fi
    
    local mutagenInstalledVersion
    mutagenInstalledVersion=$(Mutagen::getInstalledVersion)
    
    if [ -z "${mutagenInstalledVersion}" ]; then
        Console::error "Mutagen is not installed. Please install it:"
        Console::error "  brew install mutagen-io/mutagen/mutagen"
        exit 1
    fi
    
    Console::verbose "Mutagen version ${mutagenInstalledVersion} detected"
}

Registry::addChecker "Environment::checkMutagenVersion"
