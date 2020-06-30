#!/bin/bash

function String::trimWhitespaces() {
    echo "${*}" | tr -d " /n/r"
}

function String::removeColors() {
    echo -n "${1//+('\033'|'\e')[\[(]*([0-9;])[@-n]/}"
}
