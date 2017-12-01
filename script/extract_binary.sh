#!/bin/bash
# Script to extract Sony Xperia binaries
# Copyright (C) 2017 Adrien Bioteau - All Rights Reserved
# Permission to copy and modify is granted under the GPLv3 license
# Last revised 10/10/2017

setup_git() {
    git clone $1 $WORKSPACE_DIRECTORY/$2
    cd $WORKSPACE_DIRECTORY/$2
    git config --local user.email "adrien.bioteau@gmail.com"
    git config --local user.name "Adrien Bioteau"
    git checkout origin/$GIT_BRANCH
    if [ $isOdmImg == 1 ]
    then
        git rm -rf bin firmware lib lib64
    else
        git rm -rf $PLATFORM_NAME*
    fi
    cd -
}

extract_odm_image() {
    mkdir -p $WORKSPACE_DIRECTORY/$1/tmp
    simg2img $WORKSPACE_DIRECTORY/$1/*.img $WORKSPACE_DIRECTORY/$1/odm.raw.img
    sudo mount -t ext4 -o loop $WORKSPACE_DIRECTORY/$1/odm.raw.img $WORKSPACE_DIRECTORY/$1/tmp
    sudo rm -rf $WORKSPACE_DIRECTORY/$1/tmp/lost+found
    sudo chown -R $(id -u):$(id -g) $WORKSPACE_DIRECTORY/$1/tmp
    cp -rf $WORKSPACE_DIRECTORY/$1/tmp/* $2/.
    sudo umount $WORKSPACE_DIRECTORY/$1/tmp
    sudo rm -rf $WORKSPACE_DIRECTORY/$1/tmp
}

commit_files() {
    cd $WORKSPACE_DIRECTORY/$1
    git checkout -B $GIT_BRANCH
    git add .
    git commit -m "sony aosp blobs : $COMMIT_MESSAGE"
    git tag $GIT_TAG
    cd -
}

if [ $# -ne 2 ]
then
    echo "[USAGE] ./extract_binary.sh <workspace_directory> <binary_file>"
    exit 1
fi

WORKSPACE_DIRECTORY=$1
BINARY_FILE=$2

GIT_BRANCH=`echo "$BINARY_FILE" | \
    sed 's/SW_binaries_for_Xperia_AOSP_//g' | \
    sed 's/_v.*//g' | \
    tr '[:upper:]' '[:lower:]'`
if [[ $GIT_BRANCH == *"mr"* ]]
then
    GIT_BRANCH=`echo $GIT_BRANCH | sed 's/\([a-z]\)_\(mr[0-9]\)\(.*\)/\1-\2\3/g'`
else
    GIT_BRANCH=$GIT_BRANCH"-mr0"
fi

GIT_TAG=`echo "$BINARY_FILE" | \
    sed 's/SW_binaries_for_\(.*\).zip/\1/g'`

COMMIT_MESSAGE=`echo "released \`date +%Y-%m-%d\` => $GIT_TAG"`

PLATFORM_NAME=`echo "$BINARY_FILE" | \
    sed 's/SW_binaries_for_Xperia_AOSP_.*v[0-9]*\(.*\).zip/\1/g' | \
    sed 's/_//g' | \
    tr '[:upper:]' '[:lower:]'`

isOdmImg=`unzip -l orig/binary/$BINARY_FILE | grep ".img" | wc -l`

if [ $isOdmImg == 1 ]
then
    setup_git https://www.github.com/abioteau/vendor_sony_$PLATFORM_NAME.git vendor/sony/$PLATFORM_NAME
    unzip -X -b -d $WORKSPACE_DIRECTORY/vendor orig/binary/$BINARY_FILE
    extract_odm_image vendor vendor/sony/$PLATFORM_NAME
    rm -rf $WORKSPACE_DIRECTORY/vendor/*.img
    commit_files vendor/sony/$PLATFORM_NAME
else
    setup_git https://www.github.com/abioteau/vendor_sony.git vendor/sony
    unzip -X -b -d $WORKSPACE_DIRECTORY orig/binary/$BINARY_FILE
    commit_files vendor/sony
    exit `find $WORKSPACE_DIRECTORY/vendor -regextype posix-extended -regex "$WORKSPACE_DIRECTORY/vendor/sony/.*" -prune -o -type f -print | wc -l`
fi
