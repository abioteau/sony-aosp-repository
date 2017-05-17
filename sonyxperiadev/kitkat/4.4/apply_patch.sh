#!/bin/bash
# Script to apply Sony Xperia patches
# Copyright (C) 2017 Adrien Bioteau - All Rights Reserved
# Permission to copy and modify is granted under the GPLv3 license
# Last revised 05/17/2017

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
GIT_BRANCH=$5

mkdir -p $AOSP_WORKSPACE
cd $AOSP_WORKSPACE
~/bin/repo init -u $AOSP_MIRROR_URL/platform/manifest.git --repo-url $REPO_MIRROR_URL/git-repo.git -b android-4.4.4_r2

cp $ROOTDIR/sonyxperiadev/kitkat/4.4/sony.xml .repo/manifests/sony.xml
sed -i "s/fetch=\".*:\/\/github.com\/\(.*\)\"/fetch=\"$(echo $GITHUB_MIRROR_URL | sed 's/\//\\\//g')\/\1\"/" .repo/manifests/sony.xml
sed -i "/^<project/ s/name=\"/name=\"sonyxperiadev\//" .repo/manifests/sony.xml
sed -i "/^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n  <include name=\"sony.xml\"\/>\n\1/" .repo/manifests/default.xml

~/bin/repo sync -j $NB_CORES
~/bin/repo manifest -o manifest.xml -r

cd build && repo start $GIT_BRANCH .
git format-patch -o /tmp/612e2cd0e8c79bc6ab46d13cd96c01d1be382139 -1 612e2cd0e8c79bc6ab46d13cd96c01d1be382139 && git am -3 --committer-date-is-author-date /tmp/612e2cd0e8c79bc6ab46d13cd96c01d1be382139/0001-*.patch && rm -rf /tmp/612e2cd0e8c79bc6ab46d13cd96c01d1be382139
cd ..
cd hardware/qcom/bt && repo start $GIT_BRANCH .
git format-patch -o /tmp/5a6037f1c8b5ff0cf263c9e63777444ba239a056 -1 5a6037f1c8b5ff0cf263c9e63777444ba239a056 && git am -3 --committer-date-is-author-date /tmp/5a6037f1c8b5ff0cf263c9e63777444ba239a056/0001-*.patch && rm -rf /tmp/5a6037f1c8b5ff0cf263c9e63777444ba239a056
cd ../../../
cd hardware/qcom/audio && repo start $GIT_BRANCH .
git format-patch -o /tmp/00f6869a0981b570f90dbf39981734f36eafdfa9 -1 00f6869a0981b570f90dbf39981734f36eafdfa9 && git am -3 --committer-date-is-author-date /tmp/00f6869a0981b570f90dbf39981734f36eafdfa9/0001-*.patch && rm -rf /tmp/00f6869a0981b570f90dbf39981734f36eafdfa9
git format-patch -o /tmp/20bcfa8b451941843e8eabb5308f1f04f07d347a -1 20bcfa8b451941843e8eabb5308f1f04f07d347a && git am -3 --committer-date-is-author-date /tmp/20bcfa8b451941843e8eabb5308f1f04f07d347a/0001-*.patch && rm -rf /tmp/20bcfa8b451941843e8eabb5308f1f04f07d347a
cd ../../../
cd hardware/qcom/display && repo start $GIT_BRANCH .
git format-patch -o /tmp/d5ae1812a9509d8849f4494fcf17f68bf33f533c -1 d5ae1812a9509d8849f4494fcf17f68bf33f533c && git am -3 --committer-date-is-author-date /tmp/d5ae1812a9509d8849f4494fcf17f68bf33f533c/0001-*.patch && rm -rf /tmp/d5ae1812a9509d8849f4494fcf17f68bf33f533c
git format-patch -o /tmp/5898f2e789800fb196ce94532eef033e7d7e60b3 -1 5898f2e789800fb196ce94532eef033e7d7e60b3 && git am -3 --committer-date-is-author-date /tmp/5898f2e789800fb196ce94532eef033e7d7e60b3/0001-*.patch && rm -rf /tmp/5898f2e789800fb196ce94532eef033e7d7e60b3
cd ../../../

cd $ROOTDIR
