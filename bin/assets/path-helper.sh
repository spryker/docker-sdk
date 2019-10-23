#!/bin/bash

set -e

function removeTrailingSlash()
{
    local defaultSeparator=\/

    echo $1 | sed -e "s|${defaultSeparator}*$||g" -e "s|${defaultSeparator}${defaultSeparator}*|${defaultSeparator}|g"
}

export removeTrailingSlash
