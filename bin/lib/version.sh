#!/bin/bash

require awk

import lib/string.sh

function Version::parse {
    local version="$(String::trimWhitespaces "$@" | awk -F. '{ printf("%d%03d%03d%03d", $1,$2,$3,$4); }')"
    echo $((10#$version + 0))
}
