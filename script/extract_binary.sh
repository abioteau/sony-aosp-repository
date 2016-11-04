#!/bin/bash
# Script to extract Sony Xperia binaries
# Copyright (C) 2016 Adrien Bioteau - All Rights Reserved
# Permission to copy and modify is granted under the GPLv3 license
# Last revised 11/04/2016

BASEDIR=`pwd`

if [ $# -ne 5 ]
then
    echo "[USAGE] ./extract_binary.sh <workspace_directory> <binary_file> <commit_message> <git_branch> <origin_git_branch>"
    exit 1
fi

WORKSPACE_DIRECTORY=$1
BINARY_FILE=$2
COMMIT_MESSAGE=$3
GIT_BRANCH=$4
ORIGIN_GIT_BRANCH=$5

git clone https://www.github.com/abioteau/vendor_sony.git $WORKSPACE_DIRECTORY/vendor/sony -b $ORIGIN_GIT_BRANCH
rm -rf $WORKSPACE_DIRECTORY/vendor/sony/*

git clone https://www.github.com/abioteau/vendor_qcom_prebuilt.git $WORKSPACE_DIRECTORY/vendor/qcom/prebuilt -b $ORIGIN_GIT_BRANCH
rm -rf $WORKSPACE_DIRECTORY/vendor/qcom/prebuilt/*

unzip -X -b -d $WORKSPACE_DIRECTORY sonyxperiadev/binaries/$BINARY_FILE

cd $WORKSPACE_DIRECTORY/vendor/sony
git checkout -b $GIT_BRANCH
git add .
git commit -m "sony aosp blobs : $COMMIT_MESSAGE"

cd $WORKSPACE_DIRECTORY/vendor/qcom/prebuilt
git checkout -b $GIT_BRANCH
git add .
git commit -m "qcom aosp blobs : $COMMIT_MESSAGE"

cd $BASEDIR
