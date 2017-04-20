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
git checkout -f master
sed -i "s/fetch=\".*:\/\/github.com\/\(.*\)\"/fetch=\"$(echo $SONY_MIRROR_URL | sed 's/\//\\\//g')\/\1\"/" *.xml
cd ../..
~/bin/repo sync -j $NB_CORES
~/bin/repo manifest -o manifest.xml -r

cd external/toybox && git checkout -b $GIT_BRANCH
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/toybox/refs/changes/74/265074/1/*.patch`
git format-patch -o /tmp/d3e8dd1bf56afc2277960472a46907d419e4b3da -1 d3e8dd1bf56afc2277960472a46907d419e4b3da && git am -3 --committer-date-is-author-date /tmp/d3e8dd1bf56afc2277960472a46907d419e4b3da/0001-*.patch && rm -rf /tmp/d3e8dd1bf56afc2277960472a46907d419e4b3da
git format-patch -o /tmp/1c028ca33dc059a9d8f18daafcd77b5950268f41 -1 1c028ca33dc059a9d8f18daafcd77b5950268f41 && git am -3 --committer-date-is-author-date /tmp/1c028ca33dc059a9d8f18daafcd77b5950268f41/0001-*.patch && rm -rf /tmp/1c028ca33dc059a9d8f18daafcd77b5950268f41
git format-patch -o /tmp/cb49c305e3c78179b19d6f174ae73309544292b8 -1 cb49c305e3c78179b19d6f174ae73309544292b8 && git am -3 --committer-date-is-author-date /tmp/cb49c305e3c78179b19d6f174ae73309544292b8/0001-*.patch && rm -rf /tmp/cb49c305e3c78179b19d6f174ae73309544292b8
cd ../libnfc-nci && git checkout -b $GIT_BRANCH
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/libnfc-nci/refs/changes/52/371052/1/*.patch`
cd ../../hardware/qcom/audio && git checkout -b $GIT_BRANCH
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/91/294291/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/35/274235/9/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/86/333386/1/*.patch`
cd ../../../system/core && git checkout -b $GIT_BRANCH
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/52/269652/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/99/327399/1/*.patch`
cd ../../packages/apps/Music && git checkout -b $GIT_BRANCH
git format-patch -o /tmp/6036ce6127022880a3d9c99bd15db4c968f3e6a3 -1 6036ce6127022880a3d9c99bd15db4c968f3e6a3 && git am -3 --committer-date-is-author-date /tmp/6036ce6127022880a3d9c99bd15db4c968f3e6a3/0001-*.patch && rm -rf /tmp/6036ce6127022880a3d9c99bd15db4c968f3e6a3
cd ../../../




cd $ROOTDIR
