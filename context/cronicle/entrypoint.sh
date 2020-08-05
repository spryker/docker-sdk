#!/bin/bash

set -e
set -x

ROOT_DIR=/home/spryker/cronicle
CONF_DIR=$ROOT_DIR/conf
BIN_DIR=$ROOT_DIR/bin
# DATA_DIR needs to be the same as the exposed Docker volume in Dockerfile
DATA_DIR=$ROOT_DIR/data
# PLUGINS_DIR needs to be the same as the exposed Docker volume in Dockerfile
PLUGINS_DIR=$ROOT_DIR/plugins

rm -f "${ROOT_DIR}/logs/cronicle.pid"

# The env variables below are needed for Docker and cannot be overwritten
export CRONICLE_Storage__Filesystem__base_dir=${DATA_DIR}
export NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt
export CRONICLE_echo=1
export CRONICLE_foreground=1

# Only run setup when setup needs to be done
if [ ! -f "$DATA_DIR/.setup_done" ]
then
  "$BIN_DIR/control.sh" setup

#  cp "$CONF_DIR/config.json" "$CONF_DIR/config.json.origin"
#
#  if [ -f "$DATA_DIR/config.json.import" ]
#  then
#    # Move in custom configuration
#    cp "$DATA_DIR/config.json.import" "$CONF_DIR/config.json"
#  fi

  # Create plugins directory
  mkdir -p "$PLUGINS_DIR"

  # Marking setup done
  touch "$DATA_DIR/.setup_done"
fi

# Run cronicle
"$BIN_DIR/control.sh" start
