#!/bin/bash
# Script to apply Sony Xperia patches
# Copyright (C) 2016 Adrien Bioteau - All Rights Reserved
# Permission to copy and modify is granted under the GPLv3 license
# Last revised 11/04/2016

cd `dirname $0`/../../..
ROOTDIR=`pwd`

if [ $# -ne 4 ]
then
    echo "[USAGE] ./apply_patch.sh <aosp_workspace> <aosp_mirror> <sony_mirror> <git_branch>"
    exit 1
fi

AOSP_WORKSPACE=$1
AOSP_MIRROR_URL=$2
SONY_MIRROR_URL=$3
GIT_BRANCH=$4

mkdir -p $AOSP_WORKSPACE
cd $AOSP_WORKSPACE
~/bin/repo init -u $AOSP_MIRROR_URL/platform/manifest.git --repo-url $AOSP_MIRROR_URL/git-repo.git -b android-5.0.2_r3
cp $ROOTDIR/sonyxperiadev/lollipop/5.0/sony.xml .repo/manifests/sony.xml
sed -i "s/fetch=\".*\"/fetch=\"$SONY_MIRROR_URL\"/" .repo/manifests/sony.xml
sed -i "/^<project/ s/name=\"/name=\"sonyxperiadev\//" .repo/manifests/sony.xml
sed -i "/^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n  <include name=\"sony.xml\"\/>\n\1/" .repo/manifests/default.xml
~/bin/repo sync

cd hardware/qcom/bt && git checkout -b $GIT_BRANCH
git cherry-pick 5a6037f1c8b5ff0cf263c9e63777444ba239a056
cd ../display && git checkout -b $GIT_BRANCH
git revert 0fdae193307fb17bb537598ab62682edd5138b72
git cherry-pick e9e1e3a16144a2410e592f67bab8e24c60df52ea
cd ../../../external/libnfc-nci && git checkout -b $GIT_BRANCH
git fetch https://android.googlesource.com/platform/external/libnfc-nci refs/changes/42/103142/1 &amp;&amp; git cherry-pick FETCH_HEAD
git fetch https://android.googlesource.com/platform/external/libnfc-nci refs/changes/23/103123/1 &amp;&amp; git cherry-pick FETCH_HEAD
git fetch https://android.googlesource.com/platform/external/libnfc-nci refs/changes/51/97051/1 &amp;&amp; git cherry-pick FETCH_HEAD
cd ../../hardware/libhardware && git checkout -b $GIT_BRANCH
git am `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/libhardware/refs/changes/21/103221/2/*.patch`


~/bin/repo status
~/bin/repo forall -p -c git log --oneline android-5.0.2_r3..$GIT_BRANCH

cd $ROOTDIR
