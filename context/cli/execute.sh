#!/bin/bash

set -e

[ -z "${COMMAND}" ] && echo 'ERROR: COMMAND is not specified' && exit 1

zsh -c "${COMMAND}"
