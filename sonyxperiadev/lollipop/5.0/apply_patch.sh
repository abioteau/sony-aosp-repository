#!/bin/bash
if [0 -ne 2]
then
    [USAGE] ./apply_patch.sh <git_branch> <patch_directory>
    exit 1
fi

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
git am $2/sonyxperiadev/patches/platform/hardware/libhardware/refs/changes/21/103221/2/*.patch

repo status
