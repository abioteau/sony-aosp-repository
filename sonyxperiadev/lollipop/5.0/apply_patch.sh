#!/bin/bash

cd `dirname $0`/../../..
ROOTDIR=`pwd`

if [ $# -ne 2 ]
then
    echo "[USAGE] ./apply_patch.sh <git_branch> <aosp_root_directory>"
    exit 1
fi

cd $2
cd hardware/qcom/bt && git checkout -b $1
git cherry-pick 5a6037f1c8b5ff0cf263c9e63777444ba239a056
cd ../display && git checkout -b $1
git revert 0fdae193307fb17bb537598ab62682edd5138b72
git cherry-pick e9e1e3a16144a2410e592f67bab8e24c60df52ea
cd ../../../external/libnfc-nci && git checkout -b $1
git fetch https://android.googlesource.com/platform/external/libnfc-nci refs/changes/42/103142/1 &amp;&amp; git cherry-pick FETCH_HEAD
git fetch https://android.googlesource.com/platform/external/libnfc-nci refs/changes/23/103123/1 &amp;&amp; git cherry-pick FETCH_HEAD
git fetch https://android.googlesource.com/platform/external/libnfc-nci refs/changes/51/97051/1 &amp;&amp; git cherry-pick FETCH_HEAD
cd ../../hardware/libhardware && git checkout -b $1
git am `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/libhardware/refs/changes/21/103221/2/*.patch`


~/bin/repo status
~/bin/repo forall -p -c git log --oneline android-5.0.2_r3..$1

cd $ROOTDIR
