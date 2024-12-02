#!/bin/bash

function Environment::checkMutagenVersion() {
    if [[ "${_PLATFORM}" == "macos" ]]; then
        local mutagenInstalledVersion="$(Mutagen::getInstalledVersion)"

        if [[ "$mutagenInstalledVersion" == 0.18.* || "$mutagenInstalledVersion" > "0.18" ]]; then
            Console::error "Error: Mutagen version 0.18.* is not supported yet. Please, run the command to install the latest supported version.
    brew unlink mutagen && brew unlink mutagen-compose && brew install mutagen-io/mutagen/mutagen@0.17 mutagen-io/mutagen/mutagen-compose@0.17"
            exit 1
        fi
    fi
}

function Mutagen::getInstalledVersion() {
	echo $(String::trimWhitespaces "$(
         command -v mutagen >/dev/null 2>&1
         test $? -eq 0 && mutagen version
     )")
}

Registry::addChecker "Environment::checkMutagenVersion"
