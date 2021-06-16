#!/bin/bash

if [ ! -f "$DATA_DIR/.baked" ]; then
    /data/vendor/bin/console cronicle:install ${SPRYKER_CRONICLE_BASE_PATH} --install
fi

cd ${ROOT_DIR}
node bin/build.js dist
