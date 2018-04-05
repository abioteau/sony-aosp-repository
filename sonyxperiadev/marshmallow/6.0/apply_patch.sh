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
~/bin/repo init -u $AOSP_MIRROR_URL/platform/manifest.git --repo-url $REPO_MIRROR_URL/git-repo.git -b android-6.0.0_r26

cp $ROOTDIR/sonyxperiadev/marshmallow/6.0/sony.xml .repo/manifests/sony.xml
sed -i "s/fetch=\".*:\/\/github.com\/\(.*\)\"/fetch=\"$(echo $GITHUB_MIRROR_REL_URL | sed 's/\//\\\//g')\/\1\"/" .repo/manifests/sony.xml
sed -i "/^<project/ s/name=\"/name=\"sonyxperiadev\//" .repo/manifests/sony.xml
sed -i "/^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n  <include name=\"sony.xml\"\/>\n\1/" .repo/manifests/default.xml

~/bin/repo sync -j $NB_CORES
~/bin/repo manifest -o manifest.xml -r

cd external/libnfc-nci && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/libnfc-nci/refs/changes/61/170861/2/*.patch`
cd ../toybox && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/toybox/refs/changes/53/265153/1/*.patch`
cd ../../hardware/qcom/gps && repo start $GIT_BRANCH .
git revert --no-edit --no-commit 5c7552e789e4f039bebb09b972425a6cb47fc8e8 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 5c7552e789e4f039bebb09b972425a6cb47fc8e8)" --date "$(git log -1 --format="%ad" 5c7552e789e4f039bebb09b972425a6cb47fc8e8)" && unset GIT_COMMITTER_DATE
cd ../display && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/70/238470/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/52/265052/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/53/265053/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/92/265092/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/54/274454/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/55/274455/1/*.patch`
cd ../audio && repo start $GIT_BRANCH .
git cherry-pick -n 582e0a5e965897ea54ecfa5fe206797dab577a45 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 582e0a5e965897ea54ecfa5fe206797dab577a45)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 582e0a5e965897ea54ecfa5fe206797dab577a45)" --date "$(git log -1 --format="%ad" 582e0a5e965897ea54ecfa5fe206797dab577a45)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 48e428ecccee5c585a5bcc2297ea21802861df6e && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 48e428ecccee5c585a5bcc2297ea21802861df6e)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 48e428ecccee5c585a5bcc2297ea21802861df6e)" --date "$(git log -1 --format="%ad" 48e428ecccee5c585a5bcc2297ea21802861df6e)" && unset GIT_COMMITTER_DATE
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/10/250410/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/13/252313/1/*.patch`
cd ../media && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/media/refs/changes/90/258490/1/*.patch`
cd ../keymaster && repo start $GIT_BRANCH .
git cherry-pick -n 888834f9aba0609222c6e6bbd86bd6625af28746 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 888834f9aba0609222c6e6bbd86bd6625af28746)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 888834f9aba0609222c6e6bbd86bd6625af28746)" --date "$(git log -1 --format="%ad" 888834f9aba0609222c6e6bbd86bd6625af28746)" && unset GIT_COMMITTER_DATE
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/70/212570/5/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/80/212580/2/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/61/213261/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/21/245721/1/*.patch`
cd ../../broadcom/libbt && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/broadcom/libbt/refs/changes/17/114817/2/*.patch`
cd ../../../system/core && repo start $GIT_BRANCH .
git cherry-pick -n 9cb3d3ccf49bf0fd484563fbf611c68789d5b8a9 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 9cb3d3ccf49bf0fd484563fbf611c68789d5b8a9)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 9cb3d3ccf49bf0fd484563fbf611c68789d5b8a9)" --date "$(git log -1 --format="%ad" 9cb3d3ccf49bf0fd484563fbf611c68789d5b8a9)" && unset GIT_COMMITTER_DATE
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/92/269692/1/*.patch`
cd ../../packages/apps/Nfc && repo start $GIT_BRANCH .
git revert --no-edit --no-commit 988c3fff5470a1de3a880bd07fa438cc47e283c8 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 988c3fff5470a1de3a880bd07fa438cc47e283c8)" --date "$(git log -1 --format="%ad" 988c3fff5470a1de3a880bd07fa438cc47e283c8)" && unset GIT_COMMITTER_DATE
cd ../../../../../
 



cd $ROOTDIR
