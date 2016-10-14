#!/bin/bash

cd `dirname $0`/../../..
ROOTDIR=`pwd`

if [ $# -ne 2 ]
then
    echo "[USAGE] ./apply_patch.sh <git_branch> <aosp_root_directory>"
    exit 1
fi

cd $2
cd build && git checkout -b $1
git cherry-pick 612e2cd0e8c79bc6ab46d13cd96c01d1be382139
cd ..
cd hardware/qcom/bt && git checkout -b $1
git cherry-pick 5a6037f1c8b5ff0cf263c9e63777444ba239a056
cd ../../../
cd hardware/qcom/audio && git checkout -b $1
git cherry-pick 00f6869a0981b570f90dbf39981734f36eafdfa9
git cherry-pick 20bcfa8b451941843e8eabb5308f1f04f07d347a
cd ../../../
cd hardware/qcom/display && git checkout -b $1
git cherry-pick d5ae1812a9509d8849f4494fcf17f68bf33f533c
git cherry-pick 5898f2e789800fb196ce94532eef033e7d7e60b3
cd ../../../

~/bin/repo status
~/bin/repo forall -p -c git log --oneline android-4.4.4_r2..$1

cd $ROOTDIR
