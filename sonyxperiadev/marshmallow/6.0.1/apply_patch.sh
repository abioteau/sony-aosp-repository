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
~/bin/repo init -u $AOSP_MIRROR_URL/platform/manifest.git --repo-url $REPO_MIRROR_URL/git-repo.git -b android-6.0.1_r79
cd .repo
git clone $SONY_MIRROR_URL/sonyxperiadev/local_manifests.git
cd local_manifests
git checkout m-mr1
sed -i "s/fetch=\".*:\/\/github.com\/\(.*\)\"/fetch=\"$(echo $SONY_MIRROR_URL | sed 's/\//\\\//g')\/\1\"/" *.xml
cd ../..
~/bin/repo sync -j $NB_CORES
~/bin/repo manifest -o - -r

cd external/libnfc-nci && git checkout -b $GIT_BRANCH
git fetch https://android.googlesource.com/platform/external/libnfc-nci refs/changes/61/170861/2 &amp;&amp; git cherry-pick FETCH_HEAD
cd ../toybox && git checkout -b $GIT_BRANCH
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/toybox/refs/changes/53/265153/1/*.patch`
cd ../../hardware/qcom/gps && git checkout -b $GIT_BRANCH
git revert --no-edit 5c7552e789e4f039bebb09b972425a6cb47fc8e8
cd ../display && git checkout -b $GIT_BRANCH
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/70/238470/1/*.patch`
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/52/265052/1/*.patch`
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/53/265053/1/*.patch`
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/92/265092/1/*.patch`
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/54/274454/1/*.patch`
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/55/274455/1/*.patch`
cd ../audio && git checkout -b $GIT_BRANCH
git cherry-pick 582e0a5e965897ea54ecfa5fe206797dab577a45
git cherry-pick 48e428ecccee5c585a5bcc2297ea21802861df6e
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/10/250410/1/*.patch`
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/13/252313/1/*.patch`
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/84/278484/1/*.patch`
cd ../media && git checkout -b $GIT_BRANCH
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/media/refs/changes/90/258490/1/*.patch`
cd ../keymaster && git checkout -b $GIT_BRANCH
git cherry-pick 888834f9aba0609222c6e6bbd86bd6625af28746
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/70/212570/5/*.patch`
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/80/212580/2/*.patch`
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/61/213261/1/*.patch`
cd ../../broadcom/libbt && git checkout -b $GIT_BRANCH
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/broadcom/libbt/refs/changes/17/114817/2/*.patch`
cd ../wlan && git checkout -b $GIT_BRANCH
git cherry-pick b8f6f3ab4c0a5cb5cf3ca6cdb314cbb7281dffee
git cherry-pick c838e2c41df5431a44177f7b0394b2e2f58755f7
git cherry-pick 28fa9f01ebf42ba7177296429f3b6e4c29e415dd
git cherry-pick d1a5044518435d67b9d7c4ade446e6ab541722cb
git cherry-pick 3f84d1c4cc647c9906fdde85ecd7751b28c562a3
git cherry-pick ccb471625cb21d93aeabe9959d78c0dfa98d0203
git cherry-pick c8703419550b99eba5bc4aff3eb853ddfb6db7c6
cd ../../../system/core && git checkout -b $GIT_BRANCH
git cherry-pick 9cb3d3ccf49bf0fd484563fbf611c68789d5b8a9
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/92/269692/1/*.patch`
git am --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/38/327438/1/*.patch`
cd ../../packages/apps/Nfc && git checkout -b $GIT_BRANCH
git revert --no-edit 988c3fff5470a1de3a880bd07fa438cc47e283c8
cd ../../../../../



cd $ROOTDIR
