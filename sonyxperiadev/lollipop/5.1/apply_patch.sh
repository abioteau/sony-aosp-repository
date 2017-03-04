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
~/bin/repo init -u $AOSP_MIRROR_URL/platform/manifest.git --repo-url $REPO_MIRROR_URL/git-repo.git -b android-5.1.1_r30
cp $ROOTDIR/sonyxperiadev/lollipop/5.1/sony.xml .repo/manifests/sony.xml
sed -i "s/fetch=\".*\"/fetch=\"$SONY_MIRROR_URL\"/" .repo/manifests/sony.xml
sed -i "/^<project/ s/name=\"/name=\"sonyxperiadev\//" .repo/manifests/sony.xml
sed -i "/^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n  <include name=\"sony.xml\"\/>\n\1/" .repo/manifests/default.xml
~/bin/repo sync

cd hardware/qcom/bt && git checkout -b $GIT_BRANCH
git cherry-pick 5a6037f1c8b5ff0cf263c9e63777444ba239a056
cd ../audio && git checkout -b $GIT_BRANCH
git am `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/41/166941/1/*.patch`
git am `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/40/166940/1/*.patch`
cd ../display && git checkout -b $GIT_BRANCH
git revert ab05b00fefd34a761dfaf1ccaf8ad14d325873f4
cd ../../../external/libnfc-nci && git checkout -b $GIT_BRANCH
git fetch https://android.googlesource.com/platform/external/libnfc-nci refs/changes/42/103142/1 &amp;&amp; git cherry-pick FETCH_HEAD
git fetch https://android.googlesource.com/platform/external/libnfc-nci refs/changes/23/103123/1 &amp;&amp; git cherry-pick FETCH_HEAD
git fetch https://android.googlesource.com/platform/external/libnfc-nci refs/changes/51/97051/1 &amp;&amp; git cherry-pick FETCH_HEAD
git fetch https://android.googlesource.com/platform/external/libnfc-nci refs/changes/66/204666/3 &amp;&amp; git cherry-pick FETCH_HEAD
cd ../../external/libxml2 && git checkout -b $GIT_BRANCH
git am `ls $ROOTDIR/sonyxperiadev/patches/platform/external/libxml2/refs/changes/20/201520/1/*.patch`
cd ../../hardware/libhardware && git checkout -b $GIT_BRANCH
git am `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/libhardware/refs/changes/21/103221/2/*.patch`
cd ../broadcom/libbt && git checkout -b $GIT_BRANCH
git am `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/broadcom/libbt/refs/changes/13/154813/1/*.patch`



~/bin/repo status
~/bin/repo forall -p -c git log --oneline android-5.1.1_r30..$GIT_BRANCH

cd $ROOTDIR
