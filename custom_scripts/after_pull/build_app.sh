#!/bin/bash
set -e

source /app/scripts/utils.sh

cd ${CODE_DIR}

# install deps
run_command "$INSTALL_DEPS_COMMAND" "installing deps"

# build app
run_command "$BUILD_COMMAND" "build"

# if BUILD_OUTPUT_DIR is set and has content
if [ -n ${BUILD_OUTPUT_DIR} ] && [ -n "$(ls -A $BUILD_OUTPUT_DIR)" ]; then
  rsync -q -r --delete $BUILD_OUTPUT_DIR ${TARGET_DIR}
  log "Copy output folder: $BUILD_OUTPUT_DIR to target folder: ${TARGET_DIR} done."
fi

# builded command
run_command "$AFTER_BUILD_COMMANDS" "after build"

# push success message
log "Build app done. Git branch: $(parse_git_branch), commit: $(parse_git_commit), commit message: $(parse_git_message), commit author: $(parse_git_author), commit date: $(parse_git_date)." "info" "true"