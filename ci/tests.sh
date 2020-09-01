#!/bin/bash

set -a

source bin/standalone/console.sh

exitCode=0

tests=$(find ./ci/tests -name '*.test.sh' | tr '\n' ' ')

for test in $tests; do
    Console::info "*** ${test} ***"
    bash "${test}" || exitCode=1
done

exit "${exitCode}"
