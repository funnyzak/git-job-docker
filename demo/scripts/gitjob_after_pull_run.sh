#!/bin/bash

source /app/scripts/utils.sh;

# install deps
if [ -n "$INSTALL_DEPS_COMMAND" ]; then
    echo "run installing deps command: $INSTALL_DEPS_COMMAND"
    (eval "$INSTALL_DEPS_COMMAND") || (echo "installing deps failed. Aborting;"; notify_error ; exit 1)
else
    echo "no installing deps command. skiped."
fi


set -e

# build code
if [ -n "$BUILD_COMMAND" ]; then
    echo "run build command: $BUILD_COMMAND"
    (eval "$BUILD_COMMAND") || (echo "Build failed. Aborting;"; notify_error ; exit 1)
else
    echo "no build command. skiped."
fi

set +e


# copy output files  
if [ -n "$OUTPUT_DIRECTORY" ]; then
    echo -e "moving output folder: /app/code/$OUTPUT_DIRECTORY to target folder: /app/target/..."
    eval "rsync -q -r --delete $OUTPUT_DIRECTORY /app/target/"
    echo -e "moving to target dir done."
else
    echo -e "no OUTPUT_DIRECTORY set. skiped."
fi
