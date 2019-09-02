#!/usr/bin/env bash

find ./docker -name '*.sh' -exec bash -n {} \;
