#!/bin/bash
# Author: Leon<silenceace at gmail.com>

cd ${CODE_DIR}

source /app/scripts/utils.sh;

log "Start run hook script..."

run_command "$BEFORE_PULL_COMMANDS" "before pull"
run_folder_scripts "/custom_scripts/before_pull" "before pull"

log "Git pull code..."
git pull 1> /dev/null 2> /app/tmp/tmp_error_log
if [ $? -ne 0 ]; then
  log "git pull failed. Please check your GIT_REPO_URL env. error message: `cat /app/tmp/tmp_error_log`" "error" "true"
  exit 1
else
  log "git pull done."
fi

run_command "$AFTER_PULL_COMMANDS" "after pull"
run_folder_scripts "/custom_scripts/after_pull" "after pull"

run_command "$INSTALL_DEPS_COMMAND" "installing deps"

run_command "$BUILD_COMMAND" "build"

if [ -n ${BUILD_OUTPUT_DIR} ] && [ -n "$(ls -A $BUILD_OUTPUT_DIR)" ]; then
  rsync -q -r --delete $BUILD_OUTPUT_DIR ${TARGET_DIR}
  log "Copy output folder: $BUILD_OUTPUT_DIR to target folder: ${TARGET_DIR} done."
fi

run_command "$AFTER_BUILD_COMMANDS" "after build"

# push success message
log "Build app done. Git branch: $(parse_git_branch), commit: $(parse_git_commit), commit message: $(parse_git_message), commit author: $(parse_git_author), commit date: $(parse_git_date)." "info" "true"

log "Run hook script done."
