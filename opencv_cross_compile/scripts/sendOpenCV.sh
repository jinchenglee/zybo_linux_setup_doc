#!/usr/bin/env bash
source scripts/config
 
# Send compiled OpenCV to embedded board
echo "----- Sending compiled files to board"
if [ -n "${PASSWORD}" ]; then
    sshpass -p ${PASSWORD} scp -r opencv/buildCross/installation/  ${NAME}@${ADDRESS}:~/
else
    scp -r opencv/buildCross/installation/  ${NAME}@${ADDRESS}:~/
fi
