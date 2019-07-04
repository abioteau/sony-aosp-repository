#!/bin/bash
# Script to extract Sony Xperia binaries
# Copyright (C) 2019 Adrien Bioteau - All Rights Reserved
# Permission to copy and modify is granted under the GPLv3 license
# Last revised 04/07/2019

setup_git() {
    cd $1
    git config --local user.email "adrien.bioteau@gmail.com"
    git config --local user.name "Adrien Bioteau"
    git checkout origin/$GIT_BRANCH
    git rm -rf bin dsp firmware lib lib64 radio *.prop
    cd -
}

extract_odm_image() {
    mkdir -p $1/odm
    simg2img $1/*.img $1/odm.raw.img
    sudo mount -t ext4 -o loop $1/odm.raw.img $1/odm
    sudo rm -rf $1/odm/lost+found
    sudo chown -R $(id -u):$(id -g) $1/odm
    cp -rf $1/odm/* $2/.
    sudo umount $1/odm
    sudo rm -rf $1/odm
}

commit_files() {
    cd $1
    git checkout -B $GIT_BRANCH
    git add .
    git commit -m "sony aosp blobs : $COMMIT_MESSAGE"
    git tag -f $GIT_TAG
    cd -
}

if [ $# -ne 6 ]
then
    echo "[USAGE] ./extract_odm_image.sh <workspace_directory> <platform_name> <binary_file> <git_branch> <git_tag> <date_commit_message>"
    exit 1
fi

WORKSPACE_DIRECTORY=$1
PLATFORM_NAME=$2
BINARY_FILE=$3
GIT_BRANCH=$4
GIT_TAG=$5
COMMIT_MESSAGE_DATE=$6

COMMIT_MESSAGE=`echo "released $COMMIT_MESSAGE_DATE => $GIT_TAG"`

setup_git $WORKSPACE_DIRECTORY/vendor_sony_$PLATFORM_NAME
unzip -X -b -d $WORKSPACE_DIRECTORY/tmp $WORKSPACE_DIRECTORY/$BINARY_FILE
extract_odm_image $WORKSPACE_DIRECTORY/tmp $WORKSPACE_DIRECTORY/vendor_sony_$PLATFORM_NAME
rm -rf $WORKSPACE_DIRECTORY/tmp
commit_files $WORKSPACE_DIRECTORY/vendor_sony_$PLATFORM_NAME

