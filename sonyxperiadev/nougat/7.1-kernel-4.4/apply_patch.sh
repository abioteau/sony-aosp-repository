#!/bin/bash
# Script to apply Sony Xperia patches
# Copyright (C) 2017 Adrien Bioteau - All Rights Reserved
# Permission to copy and modify is granted under the GPLv3 license
# Last revised 08/29/2017

relpath () {
    [ $# -ge 1 ] && [ $# -le 2 ] || return 1
    current="${2:+"$1"}"
    target="${2:-"$1"}"
    if [[ "$target" = "http"* ]] || [[ "$current" = "http"* ]]; then
        echo "$target"
        return 0
    fi
    [ "$target" != . ] || target=/
    target="/${target##/}"
    [ "$current" != . ] || current=/
    current="${current:="/"}"
    current="/${current##/}"
    appendix="${target##/}"
    relative=''
    while appendix="${target#"$current"/}"
        [ "$current" != '/' ] && [ "$appendix" = "$target" ]; do
        if [ "$current" = "$appendix" ]; then
            relative="${relative:-.}"
            echo "${relative#/}"
            return 0
        fi
        current="${current%/*}"
        relative="$relative${relative:+/}.."
    done
    relative="$relative${relative:+${appendix:+/}}${appendix#/}"
    echo "$relative"
}

cd `dirname $0`/../../..
ROOTDIR=`pwd`
NB_CORES=`grep -c ^processor /proc/cpuinfo`

if [ $# -ne 5 ]
then
    echo "[USAGE] ./apply_patch.sh <aosp_workspace> <aosp_mirror> <repo_mirror> <github_mirror> <git_branch>"
    exit 1
fi

AOSP_WORKSPACE=$1
AOSP_MIRROR_URL=$2
REPO_MIRROR_URL=$3
GITHUB_MIRROR_URL=$4
GITHUB_MIRROR_REL_URL=$(relpath $AOSP_MIRROR_URL/platform $GITHUB_MIRROR_URL)
GIT_BRANCH=$5

mkdir -p $AOSP_WORKSPACE
cd $AOSP_WORKSPACE
~/bin/repo init -u $AOSP_MIRROR_URL/platform/manifest.git --repo-url $REPO_MIRROR_URL/git-repo.git -b android-7.1.2_r29

sed -i -e "/^  <!-- Sony AOSP addons -->/d; /^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n\1/" .repo/manifests/default.xml
git clone $GITHUB_MIRROR_URL/sonyxperiadev/local_manifests
cd local_manifests
git checkout -f n-mr1_4.4
sed -i "s/fetch=\".*:\/\/github.com\/\(.*\)\"/fetch=\"$(echo $GITHUB_MIRROR_REL_URL | sed 's/\//\\\//g')\/\1\"/" *.xml
find *.xml | xargs -I {} sed -i -e "/^  <include name=\"{}\"\/>/d; /^<\/manifest/ s/\(.*\)/  <include name=\"{}\"\/>\n\1/" ../.repo/manifests/default.xml
cp *.xml ../.repo/manifests/.
cd ..
rm -rf local_manifests
git clone $GITHUB_MIRROR_URL/abioteau/vendor_manifests
cd vendor_manifests
git checkout -f n-mr1_4.4
sed -i "s/fetch=\".*:\/\/github.com\/\(.*\)\"/fetch=\"$(echo $GITHUB_MIRROR_REL_URL | sed 's/\//\\\//g')\/\1\"/" *.xml
find *.xml | xargs -I {} sed -i -e "/^  <include name=\"{}\"\/>/d; /^<\/manifest/ s/\(.*\)/  <include name=\"{}\"\/>\n\1/" ../.repo/manifests/default.xml
cp *.xml ../.repo/manifests/.
cd ..
rm -rf vendor_manifests

~/bin/repo sync -j $NB_CORES
~/bin/repo manifest -o manifest.xml -r

cd external/toybox && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/toybox/refs/changes/74/265074/1/*.patch`
git format-patch -o /tmp/d3e8dd1bf56afc2277960472a46907d419e4b3da -1 d3e8dd1bf56afc2277960472a46907d419e4b3da && git am -3 --committer-date-is-author-date /tmp/d3e8dd1bf56afc2277960472a46907d419e4b3da/0001-*.patch && rm -rf /tmp/d3e8dd1bf56afc2277960472a46907d419e4b3da
git format-patch -o /tmp/1c028ca33dc059a9d8f18daafcd77b5950268f41 -1 1c028ca33dc059a9d8f18daafcd77b5950268f41 && git am -3 --committer-date-is-author-date /tmp/1c028ca33dc059a9d8f18daafcd77b5950268f41/0001-*.patch && rm -rf /tmp/1c028ca33dc059a9d8f18daafcd77b5950268f41
git format-patch -o /tmp/cb49c305e3c78179b19d6f174ae73309544292b8 -1 cb49c305e3c78179b19d6f174ae73309544292b8 && git am -3 --committer-date-is-author-date /tmp/cb49c305e3c78179b19d6f174ae73309544292b8/0001-*.patch && rm -rf /tmp/cb49c305e3c78179b19d6f174ae73309544292b8
cd ../libnfc-nci && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/libnfc-nci/refs/changes/52/371052/1/*.patch`
cd ../../hardware/qcom/bt && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/bt/refs/changes/99/422499/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/bt/refs/changes/00/422500/1/*.patch`
cd ../audio && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/91/294291/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/35/274235/9/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/86/333386/1/*.patch`
cd ../display && repo start $GIT_BRANCH .
git revert --no-edit --no-commit 51b4299f42c61d3a919c8e86c38a85f40902226b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit -m "`cat .git/MERGE_MSG`" --author "`git log -1 51b4299f42c61d3a919c8e86c38a85f40902226b | grep "Author: " | sed -e "s/Author: //"`" --date "`git log -1 51b4299f42c61d3a919c8e86c38a85f40902226b | grep "Date:   " | sed -e "s/Date:   //"`" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit b7d1a389b00370fc9d2a7db1268ce26271ead7e2 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit -m "`cat .git/MERGE_MSG`" --author "`git log -1 b7d1a389b00370fc9d2a7db1268ce26271ead7e2 | grep "Author: " | sed -e "s/Author: //"`" --date "`git log -1 b7d1a389b00370fc9d2a7db1268ce26271ead7e2 | grep "Date:   " | sed -e "s/Date:   //"`" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit f026d04dde743a0524235ae57e2ce8ac5364d44b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit -m "`cat .git/MERGE_MSG`" --author "`git log -1 f026d04dde743a0524235ae57e2ce8ac5364d44b | grep "Author: " | sed -e "s/Author: //"`" --date "`git log -1 f026d04dde743a0524235ae57e2ce8ac5364d44b | grep "Date:   " | sed -e "s/Date:   //"`" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit 3261eb2236252f9f2510c008fad451411a780b3b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit -m "`cat .git/MERGE_MSG`" --author "`git log -1 3261eb2236252f9f2510c008fad451411a780b3b | grep "Author: " | sed -e "s/Author: //"`" --date "`git log -1 3261eb2236252f9f2510c008fad451411a780b3b | grep "Date:   " | sed -e "s/Date:   //"`" && unset GIT_COMMITTER_DATE
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/54/274454/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/55/274455/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/35/437235/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/36/437236/1/*.patch`
cd ../media && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/media/refs/changes/39/422439/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/media/refs/changes/79/422379/1/*.patch`
cd ../keymaster && repo start $GIT_BRANCH .
git revert --no-edit --no-commit 583ecf5ed2a4be0d05229b8c6726680c3836be8b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit -m "`cat .git/MERGE_MSG`" --author "`git log -1 583ecf5ed2a4be0d05229b8c6726680c3836be8b | grep "Author: " | sed -e "s/Author: //"`" --date "`git log -1 583ecf5ed2a4be0d05229b8c6726680c3836be8b | grep "Date:   " | sed -e "s/Date:   //"`" && unset GIT_COMMITTER_DATE
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/70/212570/5/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/80/212580/2/*.patch`
cd ../../../system/core && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/52/269652/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/12/373812/1/*.patch`
cd ../extras && repo start $GIT_BRANCH .
git format-patch -o /tmp/c71eaf37486bed9163ad528f51de29dd56b34fd2 -1 c71eaf37486bed9163ad528f51de29dd56b34fd2 && git am -3 --committer-date-is-author-date /tmp/c71eaf37486bed9163ad528f51de29dd56b34fd2/0001-*.patch && rm -rf /tmp/c71eaf37486bed9163ad528f51de29dd56b34fd2
cd ../bt && repo start $GIT_BRANCH .
git format-patch -o /tmp/4e0f8cd65b4fbfd22612d1467b1c4df03829cfd6 -1 4e0f8cd65b4fbfd22612d1467b1c4df03829cfd6 && git am -3 --committer-date-is-author-date /tmp/4e0f8cd65b4fbfd22612d1467b1c4df03829cfd6/0001-*.patch && rm -rf /tmp/4e0f8cd65b4fbfd22612d1467b1c4df03829cfd6
git format-patch -o /tmp/69d7436c605222ba98604533d79b6861bd434e9b -1 69d7436c605222ba98604533d79b6861bd434e9b && git am -3 --committer-date-is-author-date /tmp/69d7436c605222ba98604533d79b6861bd434e9b/0001-*.patch && rm -rf /tmp/69d7436c605222ba98604533d79b6861bd434e9b
git format-patch -o /tmp/d9eebf7a4da76764203779e35f3d288e75b7521b -1 d9eebf7a4da76764203779e35f3d288e75b7521b && git am -3 --committer-date-is-author-date /tmp/d9eebf7a4da76764203779e35f3d288e75b7521b/0001-*.patch && rm -rf /tmp/d9eebf7a4da76764203779e35f3d288e75b7521b
git format-patch -o /tmp/de9e5d56c8d0e8f5033dd9c3d3b1d7f013709fe8 -1 de9e5d56c8d0e8f5033dd9c3d3b1d7f013709fe8 && git am -3 --committer-date-is-author-date /tmp/de9e5d56c8d0e8f5033dd9c3d3b1d7f013709fe8/0001-*.patch && rm -rf /tmp/de9e5d56c8d0e8f5033dd9c3d3b1d7f013709fe8
git format-patch -o /tmp/7ea6db20a9a1225f58fd507b51501f8c21d28c75 -1 7ea6db20a9a1225f58fd507b51501f8c21d28c75 && git am -3 --committer-date-is-author-date /tmp/7ea6db20a9a1225f58fd507b51501f8c21d28c75/0001-*.patch && rm -rf /tmp/7ea6db20a9a1225f58fd507b51501f8c21d28c75
git format-patch -o /tmp/ff6e31a55d3904770cd3cf6b2cd62f607e841dc2 -1 ff6e31a55d3904770cd3cf6b2cd62f607e841dc2 && git am -3 --committer-date-is-author-date /tmp/ff6e31a55d3904770cd3cf6b2cd62f607e841dc2/0001-*.patch && rm -rf /tmp/ff6e31a55d3904770cd3cf6b2cd62f607e841dc2
git format-patch -o /tmp/8952869a7e688440f9021da0f4cdf926f86149b6 -1 8952869a7e688440f9021da0f4cdf926f86149b6 && git am -3 --committer-date-is-author-date /tmp/8952869a7e688440f9021da0f4cdf926f86149b6/0001-*.patch && rm -rf /tmp/8952869a7e688440f9021da0f4cdf926f86149b6
cd ../../packages/apps/Music && repo start $GIT_BRANCH .
git format-patch -o /tmp/6036ce6127022880a3d9c99bd15db4c968f3e6a3 -1 6036ce6127022880a3d9c99bd15db4c968f3e6a3 && git am -3 --committer-date-is-author-date /tmp/6036ce6127022880a3d9c99bd15db4c968f3e6a3/0001-*.patch && rm -rf /tmp/6036ce6127022880a3d9c99bd15db4c968f3e6a3
cd ../../../frameworks/av && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/av/refs/changes/69/343069/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/av/refs/changes/70/343070/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/av/refs/changes/71/343071/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/av/refs/changes/92/384692/2/*.patch`
cd ../../

cd $ROOTDIR
