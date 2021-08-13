#!/bin/bash

export ROOT_DIR=/home/spryker/cronicle
export CONF_DIR=$ROOT_DIR/conf
export BIN_DIR=$ROOT_DIR/bin
# DATA_DIR needs to be the same as the exposed Docker volume in Dockerfile
export DATA_DIR=$ROOT_DIR/data
# PLUGINS_DIR needs to be the same as the exposed Docker volume in Dockerfile
export PLUGINS_DIR=$ROOT_DIR/plugins

rm -f "${ROOT_DIR}/logs/cronicled.pid"

# The env variables below are needed for Docker and cannot be overwritten
export CRONICLE_Storage__Filesystem__base_dir=${DATA_DIR}
export NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt
export CRONICLE_echo=1
export CRONICLE_foreground=1

# Only run setup when setup needs to be done
if [ ! -f "$DATA_DIR/.setup_done" ]; then
    node "$BIN_DIR/build.js" dist
    bash "$BIN_DIR/control.sh" setup

    # Create plugins directory
    mkdir -p "$PLUGINS_DIR"

    # Marking setup done
    touch "$DATA_DIR/.setup_done"
fi

# Run hook before Cronicle start
node "$BIN_DIR/hook.js" before-start

# Run cronicle
bash "$BIN_DIR/control.sh" start
