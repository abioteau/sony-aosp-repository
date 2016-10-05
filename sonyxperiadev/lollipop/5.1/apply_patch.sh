#!/bin/bash
if [0 -ne 2]
then
    [USAGE] ./apply_patch.sh <git_branch> <patch_directory>
    exit 1
fi

cd hardware/qcom/bt && git checkout -b $1
git cherry-pick 5a6037f1c8b5ff0cf263c9e63777444ba239a056
cd ../audio && git checkout -b $1
git am $2/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/41/166941/1/*.patch
git am $2/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/40/166940/1/*.patch
cd ../display && git checkout -b $1
git revert ab05b00fefd34a761dfaf1ccaf8ad14d325873f4
cd ../../../external/libnfc-nci && git checkout -b $1
git fetch https://android.googlesource.com/platform/external/libnfc-nci refs/changes/42/103142/1 &amp;&amp; git cherry-pick FETCH_HEAD
git fetch https://android.googlesource.com/platform/external/libnfc-nci refs/changes/23/103123/1 &amp;&amp; git cherry-pick FETCH_HEAD
git fetch https://android.googlesource.com/platform/external/libnfc-nci refs/changes/51/97051/1 &amp;&amp; git cherry-pick FETCH_HEAD
git fetch https://android.googlesource.com/platform/external/libnfc-nci refs/changes/66/204666/3 &amp;&amp; git cherry-pick FETCH_HEAD
cd ../../external/libxml2 && git checkout -b $1
git am $2/sonyxperiadev/patches/platform/external/libxml2/refs/changes/20/201520/1/*.patch
cd ../../hardware/libhardware && git checkout -b $1
git am $2/sonyxperiadev/patches/platform/hardware/libhardware/refs/changes/21/103221/2/*.patch
cd ../broadcom/libbt && git checkout -b $1
git am $2/sonyxperiadev/patches/platform/hardware/broadcom/libbt/refs/changes/13/154813/1/*.patch

repo status
