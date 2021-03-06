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
~/bin/repo init -u $AOSP_MIRROR_URL/platform/manifest.git --repo-url $REPO_MIRROR_URL/git-repo.git -b android-4.4.4_r2

cp $ROOTDIR/sonyxperiadev/kitkat/4.4/sony.xml .repo/manifests/sony.xml
sed -i "s/fetch=\".*:\/\/github.com\/\(.*\)\"/fetch=\"$(echo $GITHUB_MIRROR_REL_URL | sed 's/\//\\\//g')\/\1\"/" .repo/manifests/sony.xml
sed -i "/^<project/ s/name=\"/name=\"sonyxperiadev\//" .repo/manifests/sony.xml
sed -i "/^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n  <include name=\"sony.xml\"\/>\n\1/" .repo/manifests/default.xml

~/bin/repo sync -j $NB_CORES
~/bin/repo manifest -o manifest.xml -r

cd build && repo start $GIT_BRANCH .
git cherry-pick -n 612e2cd0e8c79bc6ab46d13cd96c01d1be382139 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 612e2cd0e8c79bc6ab46d13cd96c01d1be382139)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 612e2cd0e8c79bc6ab46d13cd96c01d1be382139)" --date "$(git log -1 --format="%ad" 612e2cd0e8c79bc6ab46d13cd96c01d1be382139)" && unset GIT_COMMITTER_DATE
cd ..
cd hardware/qcom/bt && repo start $GIT_BRANCH .
git cherry-pick -n 5a6037f1c8b5ff0cf263c9e63777444ba239a056 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 5a6037f1c8b5ff0cf263c9e63777444ba239a056)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 5a6037f1c8b5ff0cf263c9e63777444ba239a056)" --date "$(git log -1 --format="%ad" 5a6037f1c8b5ff0cf263c9e63777444ba239a056)" && unset GIT_COMMITTER_DATE
cd ../../../
cd hardware/qcom/audio && repo start $GIT_BRANCH .
git cherry-pick -n 00f6869a0981b570f90dbf39981734f36eafdfa9 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 00f6869a0981b570f90dbf39981734f36eafdfa9)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 00f6869a0981b570f90dbf39981734f36eafdfa9)" --date "$(git log -1 --format="%ad" 00f6869a0981b570f90dbf39981734f36eafdfa9)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 20bcfa8b451941843e8eabb5308f1f04f07d347a && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 20bcfa8b451941843e8eabb5308f1f04f07d347a)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 20bcfa8b451941843e8eabb5308f1f04f07d347a)" --date "$(git log -1 --format="%ad" 20bcfa8b451941843e8eabb5308f1f04f07d347a)" && unset GIT_COMMITTER_DATE
cd ../../../
cd hardware/qcom/display && repo start $GIT_BRANCH .
git cherry-pick -n d5ae1812a9509d8849f4494fcf17f68bf33f533c && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" d5ae1812a9509d8849f4494fcf17f68bf33f533c)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" d5ae1812a9509d8849f4494fcf17f68bf33f533c)" --date "$(git log -1 --format="%ad" d5ae1812a9509d8849f4494fcf17f68bf33f533c)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 5898f2e789800fb196ce94532eef033e7d7e60b3 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 5898f2e789800fb196ce94532eef033e7d7e60b3)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 5898f2e789800fb196ce94532eef033e7d7e60b3)" --date "$(git log -1 --format="%ad" 5898f2e789800fb196ce94532eef033e7d7e60b3)" && unset GIT_COMMITTER_DATE
cd ../../../

cd $ROOTDIR
