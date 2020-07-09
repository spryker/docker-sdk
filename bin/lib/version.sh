#!/bin/bash

require awk

function Version::parse {
    local version="$(echo -n "$@" | awk -F. '{ printf("%d%03d%03d%03d", $1,$2,$3,$4); }')"
    echo $((version + 0))
}
