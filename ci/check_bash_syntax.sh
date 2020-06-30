#!/usr/bin/env bash

bash -n ./sdk
bash -n ./deployment/default/deploy
find ./deployment/default -name '*.sh' -exec bash -n {} \;
