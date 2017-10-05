#!/bin/bash
# Script to extract Sony Xperia binaries
# Copyright (C) 2017 Adrien Bioteau - All Rights Reserved
# Permission to copy and modify is granted under the GPLv3 license
# Last revised 10/05/2017

setup_git() {
    git clone $1 $WORKSPACE_DIRECTORY/$2
    cd $WORKSPACE_DIRECTORY/$2
    git config --local user.email "adrien.bioteau@gmail.com"
    git config --local user.name "Adrien Bioteau"
    git checkout origin/$GIT_BRANCH
    git rm -rf *
    cd -
}

commit_files() {
    cd $WORKSPACE_DIRECTORY/$1
    git checkout -b $GIT_BRANCH
    git add .
    git commit -m "sony aosp blobs : $COMMIT_MESSAGE"
    git tag $TAG_NAME
    cd -
}

clean_dir() {
    rm -rf $WORKSPACE_DIRECTORY/$1
}

if [ $# -ne 5 ]
then
    echo "[USAGE] ./extract_binary.sh <workspace_directory> <binary_file> <commit_message> <git_branch> <git_tag>"
    exit 1
fi

WORKSPACE_DIRECTORY=$1
BINARY_FILE=$2
COMMIT_MESSAGE=$3
if [[ $4 == *"mr"* ]]
then
    GIT_BRANCH=`echo $4 | sed 's/\([a-z]\)_\(mr[0-9]\)\(.*\)/\1-\2\3/g'`
else
    GIT_BRANCH=$4"-mr0"
fi
TAG_NAME=$5

clean_dir vendor

setup_git https://www.github.com/abioteau/vendor_sony.git vendor/sony
setup_git https://www.github.com/abioteau/vendor_qcom_prebuilt.git vendor/qcom/prebuilt

unzip -X -b -d $WORKSPACE_DIRECTORY orig/binary/$BINARY_FILE

commit_files vendor/sony
commit_files vendor/qcom/prebuilt

exit `find $WORKSPACE_DIRECTORY/vendor -regextype posix-extended -regex "$WORKSPACE_DIRECTORY/vendor/sony/.*|$WORKSPACE_DIRECTORY/vendor/qcom/prebuilt/.*" -prune -o -type f -print | wc -l`
