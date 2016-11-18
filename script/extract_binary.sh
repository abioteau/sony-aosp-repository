#!/bin/bash
# Script to extract Sony Xperia binaries
# Copyright (C) 2016 Adrien Bioteau - All Rights Reserved
# Permission to copy and modify is granted under the GPLv3 license
# Last revised 11/04/2016

setup_git() {
  git clone $1 $WORKSPACE_DIRECTORY/$2
  cd $WORKSPACE_DIRECTORY/$2
  git config --local user.email "adrien.bioteau@gmail.com"
  git config --local user.name "Adrien Bioteau"
  git checkout $ORIGIN_GIT_BRANCH
  git rm -rf *
  cd -
}

commit_files() {
  cd $WORKSPACE_DIRECTORY/$1
  git checkout -b $GIT_BRANCH
  git add .
  git commit -m "sony aosp blobs : $COMMIT_MESSAGE"
  cd -
}

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

setup_git https://www.github.com/abioteau/vendor_nxp.git vendor/nxp
setup_git https://www.github.com/abioteau/vendor_sony.git vendor/sony
setup_git https://www.github.com/abioteau/vendor_qcom_prebuilt.git vendor/qcom/prebuilt

unzip -X -b -d $WORKSPACE_DIRECTORY sonyxperiadev/binary/$BINARY_FILE

commit_files vendor/nxp
commit_files vendor/sony
commit_files vendor/qcom/prebuilt

cd $BASEDIR
