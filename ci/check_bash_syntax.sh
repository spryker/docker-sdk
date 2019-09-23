#!/usr/bin/env bash

find ./deployment/default -name '*.sh' -exec bash -n {} \;
