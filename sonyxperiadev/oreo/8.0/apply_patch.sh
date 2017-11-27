#!/bin/bash
# Script to apply Sony Xperia patches
# Copyright (C) 2017 Adrien Bioteau - All Rights Reserved
# Permission to copy and modify is granted under the GPLv3 license
# Last revised 11/05/2017

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
~/bin/repo init -u $AOSP_MIRROR_URL/platform/manifest.git --repo-url $REPO_MIRROR_URL/git-repo.git -b android-8.0.0_r30

sed -i -e "/^  <!-- Sony AOSP addons -->/d; /^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n\1/" .repo/manifests/default.xml
git clone $GITHUB_MIRROR_URL/abioteau/local_manifests
cd local_manifests
git checkout -f master
sed -i "s/fetch=\".*:\/\/github.com\/\(.*\)\"/fetch=\"$(echo $GITHUB_MIRROR_REL_URL | sed 's/\//\\\//g')\/\1\"/" *.xml
find *.xml | xargs -I {} sed -i -e "/^  <include name=\"{}\"\/>/d; /^<\/manifest/ s/\(.*\)/  <include name=\"{}\"\/>\n\1/" ../.repo/manifests/default.xml
cp *.xml ../.repo/manifests/.
cd ..
rm -rf local_manifests

~/bin/repo sync -j $NB_CORES
~/bin/repo manifest -o manifest.xml -r

cd bionic && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/bionic/refs/changes/53/363153/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/bionic/refs/changes/92/368092/2/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/bionic/refs/changes/14/265214/21/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/bionic/refs/changes/90/497890/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/bionic/refs/changes/91/497891/2/*.patch`
cd ../build/soong && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/build/soong/refs/changes/54/266354/28/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/build/soong/refs/changes/93/266393/16/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/build/soong/refs/changes/13/365413/2/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/build/soong/refs/changes/12/367312/2/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/build/soong/refs/changes/32/367332/3/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/build/soong/refs/changes/92/367392/2/*.patch`
cd ../../bootable/recovery && repo start $GIT_BRANCH .
git format-patch -o /tmp/846012fc444e6076dabf874ed8cbdab358c2e0fb -1 846012fc444e6076dabf874ed8cbdab358c2e0fb && git am -3 --committer-date-is-author-date /tmp/846012fc444e6076dabf874ed8cbdab358c2e0fb/0001-*.patch && rm -rf /tmp/846012fc444e6076dabf874ed8cbdab358c2e0fb
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/bootable/recovery/refs/changes/35/517735/2/*.patch`
cd ../../external/wpa_supplicant_8 && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/wpa_supplicant_8/refs/changes/00/512300/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/wpa_supplicant_8/refs/changes/01/512301/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/wpa_supplicant_8/refs/changes/02/512302/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/wpa_supplicant_8/refs/changes/03/512303/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/wpa_supplicant_8/refs/changes/04/512304/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/wpa_supplicant_8/refs/changes/05/512305/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/wpa_supplicant_8/refs/changes/06/512306/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/wpa_supplicant_8/refs/changes/07/512307/1/*.patch`
cd ../../hardware/qcom/gps && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/gps/refs/changes/37/464137/1/*.patch`
cd ../audio && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/91/294291/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/86/333386/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/56/535256/1/*.patch`
cd ../media && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/media/refs/changes/39/422439/2/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/media/refs/changes/55/522855/1/*.patch`
cd ../display && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/35/437235/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/36/437236/1/*.patch`
cd ../bt && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/bt/refs/changes/17/478117/1/*.patch`
cd ../../../system/core && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/37/469437/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/92/497892/2/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/75/537175/1/*.patch`
git format-patch -o /tmp/d266d37e4cb6d0b31eb9422b73f051632ea7365f -1 d266d37e4cb6d0b31eb9422b73f051632ea7365f && git am -3 --committer-date-is-author-date /tmp/d266d37e4cb6d0b31eb9422b73f051632ea7365f/0001-*.patch && rm -rf /tmp/d266d37e4cb6d0b31eb9422b73f051632ea7365f
cd ../../frameworks/av && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/av/refs/changes/92/384692/2/*.patch`
cd ../../packages/inputmethods/LatinIME && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/packages/inputmethods/LatinIME/refs/changes/78/469478/1/*.patch`
cd ../../../

cd $ROOTDIR
