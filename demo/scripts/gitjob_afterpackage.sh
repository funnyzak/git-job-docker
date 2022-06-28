#!/bin/bash

CURRENT_TS=$(date +%s)

if [ -n ${ALIYUN_OSS_ENDPOINT} ]; then
    echo "set ossutils config."
    ossutil config -e ${ALIYUN_OSS_ENDPOINT} -i ${ALIYUN_OSS_AK_ID} -k ${ALIYUN_OSS_AK_SID} -L CH
    
    echo "sync apps start.."
    ossutil cp /app/target/release.zip oss://yyccstorage/deploy/helloworld.zip
    ossutil cp /app/target/helloworld.zip oss://kl-museum/deploy/bk/helloworld_${CURRENT_TS}.zip
    echo "sync apps done."
fi
