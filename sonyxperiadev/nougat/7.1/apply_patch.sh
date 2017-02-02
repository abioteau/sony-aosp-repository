#!/bin/bash
# Script to apply Sony Xperia patches
# Copyright (C) 2016 Adrien Bioteau - All Rights Reserved
# Permission to copy and modify is granted under the GPLv3 license
# Last revised 12/13/2016

cd `dirname $0`/../../..
ROOTDIR=`pwd`

if [ $# -ne 5 ]
then
    echo "[USAGE] ./apply_patch.sh <aosp_workspace> <aosp_mirror> <repo_mirror> <sony_mirror> <git_branch>"
    exit 1
fi

AOSP_WORKSPACE=$1
AOSP_MIRROR_URL=$2
REPO_MIRROR_URL=$3
SONY_MIRROR_URL=$(echo $4 | sed 's/\//\\\//g')
GIT_BRANCH=$5

mkdir -p $AOSP_WORKSPACE
cd $AOSP_WORKSPACE
~/bin/repo init -u $AOSP_MIRROR_URL/platform/manifest.git --repo-url $REPO_MIRROR_URL/git-repo.git -b android-7.1.1_r8
cp $ROOTDIR/sonyxperiadev/nougat/7.1/sony.xml .repo/manifests/sony.xml
sed -i "s/fetch=\".*\"/fetch=\"$SONY_MIRROR_URL\"/" .repo/manifests/sony.xml
sed -i "/^<project/ s/name=\"/name=\"sonyxperiadev\//" .repo/manifests/sony.xml
sed -i "/^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n  <include name=\"sony.xml\"\/>\n\1/" .repo/manifests/default.xml
~/bin/repo sync

cd external/toybox && git checkout -b $GIT_BRANCH
git am `ls $ROOTDIR/sonyxperiadev/patches/platform/external/toybox/refs/changes/74/265074/1/*.patch`
git cherry-pick d3e8dd1bf56afc2277960472a46907d419e4b3da
git cherry-pick 1c028ca33dc059a9d8f18daafcd77b5950268f41
git cherry-pick cb49c305e3c78179b19d6f174ae73309544292b8
cd ../../hardware/qcom/audio && git checkout -b $GIT_BRANCH
git am `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/91/294291/1/*.patch`
cd ../../../system/core && git checkout -b $GIT_BRANCH
git am `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/52/269652/1/*.patch`
git am `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/99/327399/1/*.patch`
cd ../../packages/apps/Music && git checkout -b $GIT_BRANCH
git cherry-pick 6036ce6127022880a3d9c99bd15db4c968f3e6a3
cd ../../../




~/bin/repo status
~/bin/repo forall -p -c git log --oneline android-7.1.1_r8..$GIT_BRANCH

cd $ROOTDIR
