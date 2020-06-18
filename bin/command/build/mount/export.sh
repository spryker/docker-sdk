#!/bin/bash

Registry::addCommand "export" "Command::export"

Registry::Help::command -c "${DGRAY}export${NC}" "${DGRAY}The command is not available in development mode.${NC}"

function Command::export() {
    Console::error "The command is not available in development mode. Use 'build' instead."
    exit 1
}
