#!/bin/bash

# Exit script instantly if any error is encountered
set -e

function downloadFileFromS3() {
    pipenv run aws s3 cp $1 $2
}

function downloadDirFromS3() {
    pipenv run aws s3 cp $1 $2 --recursive
}

function uploadFileToS3() {
    pipenv run aws s3 cp $1 $2 
}

#Sync folder to s3
function syncToS3() {
    pipenv run aws s3 sync $1 $2 --delete
}

function syncToS3Backround() {
    while true
    do
        syncToS3 $1 $2
        sleep 30
    done
}

LOCAL_SEQ_ALIGN_SCRIPT="seqalign.py"

echo "Downloading seqalign.py script..."
downloadFileFromS3 $SEQ_ALIGN_SCRIPT $LOCAL_SEQ_ALIGN_SCRIPT
echo "Successfully downloaded seqalign.py script."

echo "Running..."
pipenv run python3 ${LOCAL_SEQ_ALIGN_SCRIPT}

# TODO: upload results

