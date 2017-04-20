#!/bin/bash
# Script to apply Sony Xperia patches
# Copyright (C) 2017 Adrien Bioteau - All Rights Reserved
# Permission to copy and modify is granted under the GPLv3 license
# Last revised 04/18/2017

cd `dirname $0`/../../..
ROOTDIR=`pwd`
NB_CORES=2

if [ $# -ne 5 ]
then
    echo "[USAGE] ./apply_patch.sh <aosp_workspace> <aosp_mirror> <repo_mirror> <sony_mirror> <git_branch>"
    exit 1
fi

AOSP_WORKSPACE=$1
AOSP_MIRROR_URL=$2
REPO_MIRROR_URL=$3
SONY_MIRROR_URL=$4
GIT_BRANCH=$5

mkdir -p $AOSP_WORKSPACE
cd $AOSP_WORKSPACE
~/bin/repo init -u $AOSP_MIRROR_URL/platform/manifest.git --repo-url $REPO_MIRROR_URL/git-repo.git -b android-7.1.2_r2
cd .repo
git clone $SONY_MIRROR_URL/sonyxperiadev/local_manifests.git
cd local_manifests
git checkout n-mr1
sed -i "s/fetch=\".*:\/\/github.com\/\(.*\)\"/fetch=\"$(echo $SONY_MIRROR_URL | sed 's/\//\\\//g')\/\1\"/" *.xml
cd ../..
~/bin/repo sync -j $NB_CORES
~/bin/repo manifest -o - -r

cd external/toybox && git checkout -b $GIT_BRANCH
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/toybox/refs/changes/74/265074/1/*.patch`
git cherry-pick d3e8dd1bf56afc2277960472a46907d419e4b3da
git cherry-pick 1c028ca33dc059a9d8f18daafcd77b5950268f41
git cherry-pick cb49c305e3c78179b19d6f174ae73309544292b8
cd ../../hardware/qcom/audio && git checkout -b $GIT_BRANCH
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/91/294291/1/*.patch`
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/35/274235/9/*.patch`
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/86/333386/1/*.patch`
cd ../display && git checkout -b $GIT_BRANCH
git revert --no-edit 51b4299f42c61d3a919c8e86c38a85f40902226b
git revert --no-edit b7d1a389b00370fc9d2a7db1268ce26271ead7e2
git revert --no-edit f026d04dde743a0524235ae57e2ce8ac5364d44b
git revert --no-edit 3261eb2236252f9f2510c008fad451411a780b3b
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/54/274454/1/*.patch`
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/55/274455/1/*.patch`
cd ../keymaster && git checkout -b $GIT_BRANCH
git revert --no-edit 583ecf5ed2a4be0d05229b8c6726680c3836be8b
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/70/212570/5/*.patch`
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/80/212580/2/*.patch`
cd ../../../system/core && git checkout -b $GIT_BRANCH
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/52/269652/1/*.patch`
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/12/373812/1/*.patch`
cd ../../packages/apps/Music && git checkout -b $GIT_BRANCH
git cherry-pick 6036ce6127022880a3d9c99bd15db4c968f3e6a3
cd ../../../frameworks/av && git checkout -b $GIT_BRANCH
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/av/refs/changes/69/343069/1/*.patch`
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/av/refs/changes/70/343070/1/*.patch`
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/av/refs/changes/71/343071/1/*.patch`
cd ../../



cd $ROOTDIR
