#!/bin/bash

set -e 

source /app/scripts/utils.sh

cd ${CODE_DIR}

# install deps
run_command "$INSTALL_DEPS_COMMAND" "installing deps"

# build app
run_command "$BUILD_COMMAND" "build"

# if BUILD_OUTPUT_DIR is empty
if [ -z "$BUILD_OUTPUT_DIR" ]; then
  echo -e "No BUILD_OUTPUT_DIR set. skiped."
  exit 0
fi

# if BUILD_OUTPUT_DIR folder not empty
if [ -n "$(ls -A $BUILD_OUTPUT_DIR)" ]; then
  rsync -q -r --delete $BUILD_OUTPUT_DIR ${TARGET_DIR}
  log "moving output folder: $BUILD_OUTPUT_DIR to target folder: ${TARGET_DIR} done."
fi

# upload build output to oss
if [ -n ${ALIYUN_OSS_ENDPOINT} ] && [ -n ${ALIYUN_OSS_AK_ID} ] && [ -n ${ALIYUN_OSS_AK_SID} ]; then
  log "Set ossutils config."
  ossutil config -e ${ALIYUN_OSS_ENDPOINT} -i ${ALIYUN_OSS_AK_ID} -k ${ALIYUN_OSS_AK_SID} -L CH
  # zip target dir to release.zip
  zip -q -r ${TARGET_DIR}/release.zip ${TARGET_DIR}/*
  ossutil cp ${TARGET_DIR}/release.zip oss://ossbucketname/path/to/release.zip
  log "Upload ${TARGET_DIR}/release.zip to oss://ossbucketname/path/to/release.zip done."
fi

# push success message
log "Build app done. Git branch: $(parse_git_branch), commit: $(parse_git_commit), commit message: $(parse_git_message), commit author: $(parse_git_author), commit date: $(parse_git_date)." "info" "true"