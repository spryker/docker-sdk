#!/bin/bash

Registry::addCommand "help" "Command::help"
Registry::addCommand "" "Command::help"

Registry::Help::command -c "help" "Shows help page."

function Command::help() {
    Registry::printHelp
}
