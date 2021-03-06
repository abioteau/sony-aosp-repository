#!/bin/bash
# Script to apply Sony Xperia patches
# Copyright (C) 2018 Adrien Bioteau - All Rights Reserved
# Permission to copy and modify is granted under the GPLv3 license
# Last revised 04/09/2018

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
~/bin/repo init -u $AOSP_MIRROR_URL/platform/manifest.git --repo-url $REPO_MIRROR_URL/git-repo.git -b android-10.0.0_r41

sed -i -e "/^  <!-- Sony AOSP addons -->/d; /^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n\1/" .repo/manifests/default.xml
git clone $GITHUB_MIRROR_URL/abioteau/local_manifests
cd local_manifests
git checkout -f android-10.0.0_r41
sed -i "s/fetch=\".*:\/\/github.com\/\(.*\)\"/fetch=\"$(echo $GITHUB_MIRROR_REL_URL | sed 's/\//\\\//g')\/\1\"/" *.xml
find *.xml | xargs -I {} sed -i -e "/^  <include name=\"{}\"\/>/d; /^<\/manifest/ s/\(.*\)/  <include name=\"{}\"\/>\n\1/" ../.repo/manifests/default.xml
cp *.xml ../.repo/manifests/.
cd ..
rm -rf local_manifests

~/bin/repo sync -j $NB_CORES
~/bin/repo manifest -o manifest.xml -r

cd vendor/qcom/opensource/data/ipacfg-mgr/sdm845 && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/sdm845/data/ipacfg-mgr/refs/changes/23/834623/2/*.patch`
cd ../../../../../../hardware/qcom/audio && repo start $GIT_BRANCH .
git revert --no-edit --no-commit 39a2b8a03c0a8a44940ac732f636d9cc1959eff2 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 39a2b8a03c0a8a44940ac732f636d9cc1959eff2)" --date "$(git log -1 --format="%ad" 39a2b8a03c0a8a44940ac732f636d9cc1959eff2)" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit d0d5c9135fed70a25a42f09f0e32b056bc7b15a8 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" d0d5c9135fed70a25a42f09f0e32b056bc7b15a8)" --date "$(git log -1 --format="%ad" d0d5c9135fed70a25a42f09f0e32b056bc7b15a8)" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit 8e9b92d2c87e9d1cd96ef153853287cb79d5934c && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 8e9b92d2c87e9d1cd96ef153853287cb79d5934c)" --date "$(git log -1 --format="%ad" 8e9b92d2c87e9d1cd96ef153853287cb79d5934c)" && unset GIT_COMMITTER_DATE
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/99/1112099/2/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/00/1112100/2/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/14/777714/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/51/1118151/1/*.patch`
cd ../bootctrl && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/bootctrl/refs/changes/01/965401/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/bootctrl/refs/changes/93/968693/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/bootctrl/refs/changes/96/967996/3/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/bootctrl/refs/changes/87/971787/1/*.patch`
cd ../../nxp/nfc && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/nxp/nfc/refs/changes/77/980177/3/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/nxp/nfc/refs/changes/69/980169/2/*.patch`
cd ../../interfaces && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/interfaces/refs/changes/90/1320090/1/*.patch`
cd ../../frameworks/base && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/base/refs/changes/48/1295748/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/base/refs/changes/40/824340/2/*.patch`
cd ../../system/extras && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/extras/refs/changes/52/1117052/1/*.patch`
cd ../sepolicy && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/sepolicy/refs/changes/00/1185400/1/*.patch`
cd ../../packages/apps/DeskClock && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/packages/apps/DeskClock/refs/changes/26/987326/1/*.patch`
cd ../Messaging && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/packages/apps/Messaging/refs/changes/82/941082/1/*.patch`
cd ../../../

cd $ROOTDIR
