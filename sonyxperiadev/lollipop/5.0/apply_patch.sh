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
~/bin/repo init -u $AOSP_MIRROR_URL/platform/manifest.git --repo-url $REPO_MIRROR_URL/git-repo.git -b android-5.0.2_r3
cp $ROOTDIR/sonyxperiadev/lollipop/5.0/sony.xml .repo/manifests/sony.xml
sed -i "s/fetch=\".*:\/\/github.com\/\(.*\)\"/fetch=\"$(echo $SONY_MIRROR_URL | sed 's/\//\\\//g')\/\1\"/" .repo/manifests/sony.xml
sed -i "/^<project/ s/name=\"/name=\"sonyxperiadev\//" .repo/manifests/sony.xml
sed -i "/^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n  <include name=\"sony.xml\"\/>\n\1/" .repo/manifests/default.xml
~/bin/repo sync -j $NB_CORES
~/bin/repo manifest -o manifest.xml -r

cd hardware/qcom/bt && git checkout -b $GIT_BRANCH
git format-patch -o /tmp/5a6037f1c8b5ff0cf263c9e63777444ba239a056 -1 5a6037f1c8b5ff0cf263c9e63777444ba239a056 && git am -3 --committer-date-is-author-date /tmp/5a6037f1c8b5ff0cf263c9e63777444ba239a056/0001-*.patch && rm -rf /tmp/5a6037f1c8b5ff0cf263c9e63777444ba239a056
cd ../display && git checkout -b $GIT_BRANCH
git revert 0fdae193307fb17bb537598ab62682edd5138b72
git format-patch -o /tmp/e9e1e3a16144a2410e592f67bab8e24c60df52ea -1 e9e1e3a16144a2410e592f67bab8e24c60df52ea && git am -3 --committer-date-is-author-date /tmp/e9e1e3a16144a2410e592f67bab8e24c60df52ea/0001-*.patch && rm -rf /tmp/e9e1e3a16144a2410e592f67bab8e24c60df52ea
cd ../../../external/libnfc-nci && git checkout -b $GIT_BRANCH
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/libnfc-nci/refs/changes/42/103142/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/libnfc-nci/refs/changes/23/103123/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/libnfc-nci/refs/changes/51/97051/1/*.patch`
cd ../../hardware/libhardware && git checkout -b $GIT_BRANCH
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/libhardware/refs/changes/21/103221/2/*.patch`



cd $ROOTDIR
