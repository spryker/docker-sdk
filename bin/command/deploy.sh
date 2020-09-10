#!/bin/bash

Registry::Help::section "Usage in runtime:"
Registry::Help::command -s -a "<command> [-vxt]"
Registry::Help::command -s -c "cli" -a "[-vxt]"
Registry::Help::command -s -c "cli" -a "[-vxt] <command>"
Registry::Help::command -s -c "console" -a "[-vxt] <console-command>"
Registry::Help::command -s -c "testing" -a "[-vxt]"
Registry::Help::command -s -c "testing" -a "[-vxt] <command>"

Registry::Help::section "Options"
Registry::Help::row "" "${GREEN}-v${NC} ${HELP_DESC}Enables verbose mode. You can set environment variable ${CYAN}VERBOSE=1${HELP_DESC} instead of using this option.${NC}"
Registry::Help::row "" "${GREEN}-x${NC} $([ -z "${SPRYKER_XDEBUG_MODE_ENABLE}" ] && echo "${WARN}[DISABLED]${NC} " || echo '')${HELP_DESC}Enables Xdebug. You can set environment variable ${CYAN}SPRYKER_XDEBUG_ENABLE=1${HELP_DESC} instead of using this option.${NC}"
Registry::Help::row "" "${GREEN}-t${NC} ${HELP_DESC}Enables testing mode. You can set environment variable ${CYAN}SPRYKER_TESTING_ENABLE=1${HELP_DESC} instead of using this option.${NC}"
