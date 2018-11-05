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
~/bin/repo init -u $AOSP_MIRROR_URL/platform/manifest.git --repo-url $REPO_MIRROR_URL/git-repo.git -b android-9.0.0_r10

sed -i -e "/^  <!-- Sony AOSP addons -->/d; /^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n\1/" .repo/manifests/default.xml
git clone $GITHUB_MIRROR_URL/abioteau/local_manifests
cd local_manifests
git checkout -f android-9.0.0_r10
sed -i "s/fetch=\".*:\/\/github.com\/\(.*\)\"/fetch=\"$(echo $GITHUB_MIRROR_REL_URL | sed 's/\//\\\//g')\/\1\"/" *.xml
find *.xml | xargs -I {} sed -i -e "/^  <include name=\"{}\"\/>/d; /^<\/manifest/ s/\(.*\)/  <include name=\"{}\"\/>\n\1/" ../.repo/manifests/default.xml
cp *.xml ../.repo/manifests/.
cd ..
rm -rf local_manifests

~/bin/repo sync -j $NB_CORES
~/bin/repo manifest -o manifest.xml -r

cd hardware/qcom/gps && repo start $GIT_BRANCH .
git revert --no-edit --no-commit 484979c524067125b56d59afb102003ff48e3702 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 484979c524067125b56d59afb102003ff48e3702)" --date "$(git log -1 --format="%ad" 484979c524067125b56d59afb102003ff48e3702)" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit f475797d3c031ae97a393fa3e899034836fe7ba6 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" f475797d3c031ae97a393fa3e899034836fe7ba6)" --date "$(git log -1 --format="%ad" f475797d3c031ae97a393fa3e899034836fe7ba6)" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit 35a95e0a9bc9aeab1bb1847180babda2da5fbf90 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 35a95e0a9bc9aeab1bb1847180babda2da5fbf90)" --date "$(git log -1 --format="%ad" 35a95e0a9bc9aeab1bb1847180babda2da5fbf90)" && unset GIT_COMMITTER_DATE
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/sdm845/gps/refs/changes/39/804439/1/*.patch`
cd ../audio && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/49/728149/5/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/50/728150/4/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/51/728151/3/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/52/728152/4/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/53/728153/3/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/14/777714/1/*.patch`
cd ../media && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/media/refs/changes/39/728339/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/media/refs/changes/54/813054/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/media/refs/changes/55/813055/1/*.patch`
cd ../display && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/09/729209/2/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/10/729210/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/11/729211/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/12/729212/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/13/729213/1/*.patch`
cd ../bt && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/bt/refs/changes/69/728569/1/*.patch`
cd ../bootctrl && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/bootctrl/refs/changes/70/728570/2/*.patch`
cd ../../nxp/nfc && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/nxp/nfc/refs/changes/61/744361/2/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/nxp/nfc/refs/changes/62/744362/5/*.patch`
cd ../../../frameworks/base && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/base/refs/changes/15/727815/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/base/refs/changes/75/728575/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/base/refs/changes/05/728605/1/*.patch`
cd ../../system/core && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/01/741001/2/*.patch`
cd ../../

cd $ROOTDIR
