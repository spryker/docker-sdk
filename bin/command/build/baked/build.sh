#!/bin/bash

Registry::addCommand "build" "Command::build"

Registry::Help::command -c "${DGRAY}build${NC}" "${DGRAY}The command is not available in non-development mode.${NC}"

function Command::build() {
    Console::error "The command is not available in non-development mode. Use 'export' instead."
    exit 1
}
