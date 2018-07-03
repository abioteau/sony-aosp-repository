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
~/bin/repo init -u $AOSP_MIRROR_URL/platform/manifest.git --repo-url $REPO_MIRROR_URL/git-repo.git -b android-7.1.2_r36

sed -i -e "/^  <!-- Sony AOSP addons -->/d; /^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n\1/" .repo/manifests/default.xml
git clone $GITHUB_MIRROR_URL/abioteau/local_manifests
cd local_manifests
git checkout -f android-7.1.2_r36
sed -i "s/fetch=\".*:\/\/github.com\/\(.*\)\"/fetch=\"$(echo $GITHUB_MIRROR_REL_URL | sed 's/\//\\\//g')\/\1\"/" *.xml
find *.xml | xargs -I {} sed -i -e "/^  <include name=\"{}\"\/>/d; /^<\/manifest/ s/\(.*\)/  <include name=\"{}\"\/>\n\1/" ../.repo/manifests/default.xml
cp *.xml ../.repo/manifests/.
cd ..
rm -rf local_manifests

~/bin/repo sync -j $NB_CORES
~/bin/repo manifest -o manifest.xml -r

cd bionic && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/bionic/refs/changes/50/234150/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/bionic/refs/changes/53/236953/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/bionic/refs/changes/90/497890/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/bionic/refs/changes/01/503201/1/*.patch`
cd ../bootable/recovery && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/bootable/recovery/refs/changes/15/538015/2/*.patch`
cd ../../build && repo start $GIT_BRANCH .
git cherry-pick -n 2b8f489e304e1afd7ae607000d5e7022328293db && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 2b8f489e304e1afd7ae607000d5e7022328293db)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 2b8f489e304e1afd7ae607000d5e7022328293db)" --date "$(git log -1 --format="%ad" 2b8f489e304e1afd7ae607000d5e7022328293db)" && unset GIT_COMMITTER_DATE
cd ../external/toybox && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/toybox/refs/changes/74/265074/1/*.patch`
git cherry-pick -n d3e8dd1bf56afc2277960472a46907d419e4b3da && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" d3e8dd1bf56afc2277960472a46907d419e4b3da)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" d3e8dd1bf56afc2277960472a46907d419e4b3da)" --date "$(git log -1 --format="%ad" d3e8dd1bf56afc2277960472a46907d419e4b3da)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 1c028ca33dc059a9d8f18daafcd77b5950268f41 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 1c028ca33dc059a9d8f18daafcd77b5950268f41)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 1c028ca33dc059a9d8f18daafcd77b5950268f41)" --date "$(git log -1 --format="%ad" 1c028ca33dc059a9d8f18daafcd77b5950268f41)" && unset GIT_COMMITTER_DATE
git cherry-pick -n cb49c305e3c78179b19d6f174ae73309544292b8 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" cb49c305e3c78179b19d6f174ae73309544292b8)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" cb49c305e3c78179b19d6f174ae73309544292b8)" --date "$(git log -1 --format="%ad" cb49c305e3c78179b19d6f174ae73309544292b8)" && unset GIT_COMMITTER_DATE
cd ../iproute2 && repo start $GIT_BRANCH .
git cherry-pick -n 04cd308001d732a1c8e5d244daba37c56a4641b0 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 04cd308001d732a1c8e5d244daba37c56a4641b0)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 04cd308001d732a1c8e5d244daba37c56a4641b0)" --date "$(git log -1 --format="%ad" 04cd308001d732a1c8e5d244daba37c56a4641b0)" && unset GIT_COMMITTER_DATE
cd ../libnfc-nci && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/libnfc-nci/refs/changes/52/371052/1/*.patch`
cd ../../hardware/qcom/bt && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/bt/refs/changes/99/422499/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/bt/refs/changes/00/422500/1/*.patch`
cd ../audio && repo start $GIT_BRANCH .
git cherry-pick -n f1346ce3f446e6a89f39748bf319949fb54036a3 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" f1346ce3f446e6a89f39748bf319949fb54036a3)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" f1346ce3f446e6a89f39748bf319949fb54036a3)" --date "$(git log -1 --format="%ad" f1346ce3f446e6a89f39748bf319949fb54036a3)" && unset GIT_COMMITTER_DATE
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/91/294291/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/86/333386/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/55/535255/1/*.patch`
cd ../display && repo start $GIT_BRANCH .
git revert --no-edit --no-commit 51b4299f42c61d3a919c8e86c38a85f40902226b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 51b4299f42c61d3a919c8e86c38a85f40902226b)" --date "$(git log -1 --format="%ad" 51b4299f42c61d3a919c8e86c38a85f40902226b)" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit b7d1a389b00370fc9d2a7db1268ce26271ead7e2 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" b7d1a389b00370fc9d2a7db1268ce26271ead7e2)" --date "$(git log -1 --format="%ad" b7d1a389b00370fc9d2a7db1268ce26271ead7e2)" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit f026d04dde743a0524235ae57e2ce8ac5364d44b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" f026d04dde743a0524235ae57e2ce8ac5364d44b)" --date "$(git log -1 --format="%ad" f026d04dde743a0524235ae57e2ce8ac5364d44b)" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit 3261eb2236252f9f2510c008fad451411a780b3b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 3261eb2236252f9f2510c008fad451411a780b3b)" --date "$(git log -1 --format="%ad" 3261eb2236252f9f2510c008fad451411a780b3b)" && unset GIT_COMMITTER_DATE
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/54/274454/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/55/274455/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/35/437235/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/36/437236/1/*.patch`
cd ../media && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/media/refs/changes/39/422439/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/media/refs/changes/79/422379/1/*.patch`
cd ../keymaster && repo start $GIT_BRANCH .
git revert --no-edit --no-commit 583ecf5ed2a4be0d05229b8c6726680c3836be8b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 583ecf5ed2a4be0d05229b8c6726680c3836be8b)" --date "$(git log -1 --format="%ad" 583ecf5ed2a4be0d05229b8c6726680c3836be8b)" && unset GIT_COMMITTER_DATE
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/70/212570/5/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/80/212580/2/*.patch`
cd ../../../system/core && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/52/269652/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/12/373812/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/75/537175/1/*.patch`
cd ../extras && repo start $GIT_BRANCH .
git cherry-pick -n c71eaf37486bed9163ad528f51de29dd56b34fd2 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" c71eaf37486bed9163ad528f51de29dd56b34fd2)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" c71eaf37486bed9163ad528f51de29dd56b34fd2)" --date "$(git log -1 --format="%ad" c71eaf37486bed9163ad528f51de29dd56b34fd2)" && unset GIT_COMMITTER_DATE
cd ../netd && repo start $GIT_BRANCH .
git cherry-pick -n 2b078678aafceeefea6a70e96ab8ddefe515d027 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 2b078678aafceeefea6a70e96ab8ddefe515d027)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 2b078678aafceeefea6a70e96ab8ddefe515d027)" --date "$(git log -1 --format="%ad" 2b078678aafceeefea6a70e96ab8ddefe515d027)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 882e467ff7b83de868fa0b9a9beb9036bf14aede && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 882e467ff7b83de868fa0b9a9beb9036bf14aede)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 882e467ff7b83de868fa0b9a9beb9036bf14aede)" --date "$(git log -1 --format="%ad" 882e467ff7b83de868fa0b9a9beb9036bf14aede)" && unset GIT_COMMITTER_DATE
cd ../../packages/apps/Camera2 && repo start $GIT_BRANCH .
git cherry-pick -n 8b17de0f4321fd981da98c64ad8a379ed6c0432a && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 8b17de0f4321fd981da98c64ad8a379ed6c0432a)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 8b17de0f4321fd981da98c64ad8a379ed6c0432a)" --date "$(git log -1 --format="%ad" 8b17de0f4321fd981da98c64ad8a379ed6c0432a)" && unset GIT_COMMITTER_DATE
cd ../Music && repo start $GIT_BRANCH .
git cherry-pick -n 6036ce6127022880a3d9c99bd15db4c968f3e6a3 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 6036ce6127022880a3d9c99bd15db4c968f3e6a3)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 6036ce6127022880a3d9c99bd15db4c968f3e6a3)" --date "$(git log -1 --format="%ad" 6036ce6127022880a3d9c99bd15db4c968f3e6a3)" && unset GIT_COMMITTER_DATE
cd ../../../frameworks/av && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/av/refs/changes/69/343069/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/av/refs/changes/70/343070/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/av/refs/changes/71/343071/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/av/refs/changes/92/384692/2/*.patch`
cd ../../

cd $ROOTDIR
