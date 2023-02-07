#!/bin/bash

source /app/scripts/utils.sh;

log "Start run hook script..."

cd ${CODE_DIR}

run_command "$BEFORE_PULL_COMMANDS" "before pull"
run_folder_scripts "/custom_scripts/before_pull" "before pull"

log "Git pull code..."
git pull 2>tmp_error_log
if [ $? -ne 0 ]; then
  log "git pull failed. Please check your GIT_REPO env. error message: `cat tmp_error_log`" "error" "true"
  exit 1
else
  log "git pull done."
fi

run_command "$AFTER_PULL_COMMANDS" "after pull"
run_folder_scripts "/custom_scripts/after_pull" "after pull"

log "Run hook script done."
