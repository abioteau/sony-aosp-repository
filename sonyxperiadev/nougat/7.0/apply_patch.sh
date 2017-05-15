#!/bin/bash
# Script to apply Sony Xperia patches
# Copyright (C) 2017 Adrien Bioteau - All Rights Reserved
# Permission to copy and modify is granted under the GPLv3 license
# Last revised 05/15/2017

cd `dirname $0`/../../..
ROOTDIR=`pwd`
NB_CORES=`grep -c ^processor /proc/cpuinfo`

if [ $# -ne 5 ]
then
    echo "[USAGE] ./apply_patch.sh <aosp_workspace> <aosp_mirror> <repo_mirror> <sony_mirror> <git_branch>"
    exit 1
fi

AOSP_WORKSPACE=$1
AOSP_MIRROR_URL=$2
REPO_MIRROR_URL=$3
SONY_MIRROR_URL=$4
GIT_BRANCH=$5

mkdir -p $AOSP_WORKSPACE
cd $AOSP_WORKSPACE
~/bin/repo init -u $AOSP_MIRROR_URL/platform/manifest.git --repo-url $REPO_MIRROR_URL/git-repo.git -b android-7.0.0_r32
cd .repo
git clone $SONY_MIRROR_URL/sonyxperiadev/local_manifests.git
cd local_manifests
git checkout -f n-mr0
sed -i "s/fetch=\".*:\/\/github.com\/\(.*\)\"/fetch=\"$(echo $SONY_MIRROR_URL | sed 's/\//\\\//g')\/\1\"/" *.xml
cd ../..
~/bin/repo sync -j $NB_CORES
~/bin/repo manifest -o manifest.xml -r

cd external/toybox && git checkout -b $GIT_BRANCH
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/toybox/refs/changes/74/265074/1/*.patch`
git format-patch -o /tmp/d3e8dd1bf56afc2277960472a46907d419e4b3da -1 d3e8dd1bf56afc2277960472a46907d419e4b3da && git am -3 --committer-date-is-author-date /tmp/d3e8dd1bf56afc2277960472a46907d419e4b3da/0001-*.patch && rm -rf /tmp/d3e8dd1bf56afc2277960472a46907d419e4b3da
git format-patch -o /tmp/1c028ca33dc059a9d8f18daafcd77b5950268f41 -1 1c028ca33dc059a9d8f18daafcd77b5950268f41 && git am -3 --committer-date-is-author-date /tmp/1c028ca33dc059a9d8f18daafcd77b5950268f41/0001-*.patch && rm -rf /tmp/1c028ca33dc059a9d8f18daafcd77b5950268f41
git format-patch -o /tmp/cb49c305e3c78179b19d6f174ae73309544292b8 -1 cb49c305e3c78179b19d6f174ae73309544292b8 && git am -3 --committer-date-is-author-date /tmp/cb49c305e3c78179b19d6f174ae73309544292b8/0001-*.patch && rm -rf /tmp/cb49c305e3c78179b19d6f174ae73309544292b8
cd ../../hardware/qcom/audio && git checkout -b $GIT_BRANCH
git format-patch -o /tmp/1d2e4743ffcbd27ed2e96c1c8ac1e186a717fa45 -1 1d2e4743ffcbd27ed2e96c1c8ac1e186a717fa45 && git am -3 --committer-date-is-author-date /tmp/1d2e4743ffcbd27ed2e96c1c8ac1e186a717fa45/0001-*.patch && rm -rf /tmp/1d2e4743ffcbd27ed2e96c1c8ac1e186a717fa45
git format-patch -o /tmp/a8d7c9257c3c9514f5c35d3dbd987703e12c82cd -1 a8d7c9257c3c9514f5c35d3dbd987703e12c82cd && git am -3 --committer-date-is-author-date /tmp/a8d7c9257c3c9514f5c35d3dbd987703e12c82cd/0001-*.patch && rm -rf /tmp/a8d7c9257c3c9514f5c35d3dbd987703e12c82cd
git format-patch -o /tmp/6b4b127cad4dce4db30c5119d8fd6bbc0af3924c -1 6b4b127cad4dce4db30c5119d8fd6bbc0af3924c && git am -3 --committer-date-is-author-date /tmp/6b4b127cad4dce4db30c5119d8fd6bbc0af3924c/0001-*.patch && rm -rf /tmp/6b4b127cad4dce4db30c5119d8fd6bbc0af3924c
git format-patch -o /tmp/9ebf582bd7f0b701f969081646d27c4a77347402 -1 9ebf582bd7f0b701f969081646d27c4a77347402 && git am -3 --committer-date-is-author-date /tmp/9ebf582bd7f0b701f969081646d27c4a77347402/0001-*.patch && rm -rf /tmp/9ebf582bd7f0b701f969081646d27c4a77347402
git format-patch -o /tmp/536daa591913c5eaf3fea47c90a5cf4bc24ce321 -1 536daa591913c5eaf3fea47c90a5cf4bc24ce321 && git am -3 --committer-date-is-author-date /tmp/536daa591913c5eaf3fea47c90a5cf4bc24ce321/0001-*.patch && rm -rf /tmp/536daa591913c5eaf3fea47c90a5cf4bc24ce321
git format-patch -o /tmp/152b09a14f3b2c17063468b3f5b5ddda195802ec -1 152b09a14f3b2c17063468b3f5b5ddda195802ec && git am -3 --committer-date-is-author-date /tmp/152b09a14f3b2c17063468b3f5b5ddda195802ec/0001-*.patch && rm -rf /tmp/152b09a14f3b2c17063468b3f5b5ddda195802ec
git format-patch -o /tmp/6ebefdd83d29132f6ca5a5d6b45cac71871dd037 -1 6ebefdd83d29132f6ca5a5d6b45cac71871dd037 && git am -3 --committer-date-is-author-date /tmp/6ebefdd83d29132f6ca5a5d6b45cac71871dd037/0001-*.patch && rm -rf /tmp/6ebefdd83d29132f6ca5a5d6b45cac71871dd037
git format-patch -o /tmp/56631b51985194269339dbf53316f414b3d21050 -1 56631b51985194269339dbf53316f414b3d21050 && git am -3 --committer-date-is-author-date /tmp/56631b51985194269339dbf53316f414b3d21050/0001-*.patch && rm -rf /tmp/56631b51985194269339dbf53316f414b3d21050
git format-patch -o /tmp/2d809e0d104497ca6b7a1e1be4efdf7856070aa5 -1 2d809e0d104497ca6b7a1e1be4efdf7856070aa5 && git am -3 --committer-date-is-author-date /tmp/2d809e0d104497ca6b7a1e1be4efdf7856070aa5/0001-*.patch && rm -rf /tmp/2d809e0d104497ca6b7a1e1be4efdf7856070aa5
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/35/274235/6/*.patch`
cd ../bt && git checkout -b $GIT_BRANCH
git revert --no-edit --no-commit c7dc913784965e4ce705c2045f0a8b43fcd1db1c && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit -m "`cat .git/MERGE_MSG`" --author "`git log -1 c7dc913784965e4ce705c2045f0a8b43fcd1db1c | grep "Author: " | sed -e "s/Author: //"`" --date "`git log -1 c7dc913784965e4ce705c2045f0a8b43fcd1db1c | grep "Date:   " | sed -e "s/Date:   //"`" && unset GIT_COMMITTER_DATE
cd ../display && git checkout -b $GIT_BRANCH
git revert --no-edit --no-commit b7d1a389b00370fc9d2a7db1268ce26271ead7e2 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit -m "`cat .git/MERGE_MSG`" --author "`git log -1 b7d1a389b00370fc9d2a7db1268ce26271ead7e2 | grep "Author: " | sed -e "s/Author: //"`" --date "`git log -1 b7d1a389b00370fc9d2a7db1268ce26271ead7e2 | grep "Date:   " | sed -e "s/Date:   //"`" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit f026d04dde743a0524235ae57e2ce8ac5364d44b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit -m "`cat .git/MERGE_MSG`" --author "`git log -1 f026d04dde743a0524235ae57e2ce8ac5364d44b | grep "Author: " | sed -e "s/Author: //"`" --date "`git log -1 f026d04dde743a0524235ae57e2ce8ac5364d44b | grep "Date:   " | sed -e "s/Date:   //"`" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit 3261eb2236252f9f2510c008fad451411a780b3b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit -m "`cat .git/MERGE_MSG`" --author "`git log -1 3261eb2236252f9f2510c008fad451411a780b3b | grep "Author: " | sed -e "s/Author: //"`" --date "`git log -1 3261eb2236252f9f2510c008fad451411a780b3b | grep "Date:   " | sed -e "s/Date:   //"`" && unset GIT_COMMITTER_DATE
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/72/265072/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/73/265073/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/54/274454/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/55/274455/1/*.patch`
cd ../gps && git checkout -b $GIT_BRANCH
git revert --no-edit --no-commit 53bf15aab71461f81e27e6f5176afcd1a29af7d4 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit -m "`cat .git/MERGE_MSG`" --author "`git log -1 53bf15aab71461f81e27e6f5176afcd1a29af7d4 | grep "Author: " | sed -e "s/Author: //"`" --date "`git log -1 53bf15aab71461f81e27e6f5176afcd1a29af7d4 | grep "Date:   " | sed -e "s/Date:   //"`" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit 486ab751599b7f8b5a2f2711d22867ad54fdc79b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit -m "`cat .git/MERGE_MSG`" --author "`git log -1 486ab751599b7f8b5a2f2711d22867ad54fdc79b | grep "Author: " | sed -e "s/Author: //"`" --date "`git log -1 486ab751599b7f8b5a2f2711d22867ad54fdc79b | grep "Date:   " | sed -e "s/Date:   //"`" && unset GIT_COMMITTER_DATE
cd ../media && git checkout -b $GIT_BRANCH
git revert --no-edit --no-commit 9e8b76d32ece15e79ebf4b02ede869d89807eec6 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit -m "`cat .git/MERGE_MSG`" --author "`git log -1 9e8b76d32ece15e79ebf4b02ede869d89807eec6 | grep "Author: " | sed -e "s/Author: //"`" --date "`git log -1 9e8b76d32ece15e79ebf4b02ede869d89807eec6 | grep "Date:   " | sed -e "s/Date:   //"`" && unset GIT_COMMITTER_DATE
cd ../keymaster && git checkout -b $GIT_BRANCH
git revert --no-edit --no-commit 583ecf5ed2a4be0d05229b8c6726680c3836be8b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit -m "`cat .git/MERGE_MSG`" --author "`git log -1 583ecf5ed2a4be0d05229b8c6726680c3836be8b | grep "Author: " | sed -e "s/Author: //"`" --date "`git log -1 583ecf5ed2a4be0d05229b8c6726680c3836be8b | grep "Date:   " | sed -e "s/Date:   //"`" && unset GIT_COMMITTER_DATE
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/70/212570/5/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/80/212580/2/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/61/213261/1/*.patch`
cd ../../../system/core && git checkout -b $GIT_BRANCH
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/52/269652/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/58/327458/1/*.patch`
cd ../../packages/apps/Nfc && git checkout -b $GIT_BRANCH
git revert --no-edit --no-commit 988c3fff5470a1de3a880bd07fa438cc47e283c8 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit -m "`cat .git/MERGE_MSG`" --author "`git log -1 988c3fff5470a1de3a880bd07fa438cc47e283c8 | grep "Author: " | sed -e "s/Author: //"`" --date "`git log -1 988c3fff5470a1de3a880bd07fa438cc47e283c8 | grep "Date:   " | sed -e "s/Date:   //"`" && unset GIT_COMMITTER_DATE
cd ../Music && git checkout -b $GIT_BRANCH
git format-patch -o /tmp/6036ce6127022880a3d9c99bd15db4c968f3e6a3 -1 6036ce6127022880a3d9c99bd15db4c968f3e6a3 && git am -3 --committer-date-is-author-date /tmp/6036ce6127022880a3d9c99bd15db4c968f3e6a3/0001-*.patch && rm -rf /tmp/6036ce6127022880a3d9c99bd15db4c968f3e6a3
cd ../../../frameworks/av && git checkout -b $GIT_BRANCH
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/av/refs/changes/71/316171/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/av/refs/changes/72/316172/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/av/refs/changes/73/316173/1/*.patch`
cd ../..



cd $ROOTDIR
