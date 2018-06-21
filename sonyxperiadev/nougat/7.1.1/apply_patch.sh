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
~/bin/repo init -u $AOSP_MIRROR_URL/platform/manifest.git --repo-url $REPO_MIRROR_URL/git-repo.git -b android-7.1.1_r55

sed -i -e "/^  <!-- Sony AOSP addons -->/d; /^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n\1/" .repo/manifests/default.xml
git clone $GITHUB_MIRROR_URL/abioteau/local_manifests
cd local_manifests
git checkout -f android-7.1.1_r55
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
git cherry-pick -n 35fff61b1c0d736d090a1cd1bb4e99141cc88ad8 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 35fff61b1c0d736d090a1cd1bb4e99141cc88ad8)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 35fff61b1c0d736d090a1cd1bb4e99141cc88ad8)" --date "$(git log -1 --format="%ad" 35fff61b1c0d736d090a1cd1bb4e99141cc88ad8)" && unset GIT_COMMITTER_DATE
git cherry-pick -n d00f5eb63a8e4690f9bef1e943d539d052444d9b && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" d00f5eb63a8e4690f9bef1e943d539d052444d9b)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" d00f5eb63a8e4690f9bef1e943d539d052444d9b)" --date "$(git log -1 --format="%ad" d00f5eb63a8e4690f9bef1e943d539d052444d9b)" && unset GIT_COMMITTER_DATE
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/bootable/recovery/refs/changes/15/538015/2/*.patch`
cd ../../build && repo start $GIT_BRANCH .
git cherry-pick -n 47ec5ab561bd979560bde402201268486ce9cc34 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 47ec5ab561bd979560bde402201268486ce9cc34)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 47ec5ab561bd979560bde402201268486ce9cc34)" --date "$(git log -1 --format="%ad" 47ec5ab561bd979560bde402201268486ce9cc34)" && unset GIT_COMMITTER_DATE
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
git cherry-pick -n 9340e065671f2defd5be2a4aac616a15b2c584c6 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 9340e065671f2defd5be2a4aac616a15b2c584c6)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 9340e065671f2defd5be2a4aac616a15b2c584c6)" --date "$(git log -1 --format="%ad" 9340e065671f2defd5be2a4aac616a15b2c584c6)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 6572a3ba8186fc719c0f81de8820fb8d3009d0a0 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 6572a3ba8186fc719c0f81de8820fb8d3009d0a0)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 6572a3ba8186fc719c0f81de8820fb8d3009d0a0)" --date "$(git log -1 --format="%ad" 6572a3ba8186fc719c0f81de8820fb8d3009d0a0)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 661a4bab919e4761e2b782474badb19f14ce3388 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 661a4bab919e4761e2b782474badb19f14ce3388)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 661a4bab919e4761e2b782474badb19f14ce3388)" --date "$(git log -1 --format="%ad" 661a4bab919e4761e2b782474badb19f14ce3388)" && unset GIT_COMMITTER_DATE
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/bt/refs/changes/99/422499/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/bt/refs/changes/00/422500/1/*.patch`
cd ../audio && repo start $GIT_BRANCH .
git cherry-pick -n 0cfc50a503fb058011b7fef517488f6df4c419e5 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 0cfc50a503fb058011b7fef517488f6df4c419e5)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 0cfc50a503fb058011b7fef517488f6df4c419e5)" --date "$(git log -1 --format="%ad" 0cfc50a503fb058011b7fef517488f6df4c419e5)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 8a8deaa00035aa29968201eadbc9fe32eb5ad675 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 8a8deaa00035aa29968201eadbc9fe32eb5ad675)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 8a8deaa00035aa29968201eadbc9fe32eb5ad675)" --date "$(git log -1 --format="%ad" 8a8deaa00035aa29968201eadbc9fe32eb5ad675)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 65dba39450a26f659fc6a14c1cbb2003681972ba && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 65dba39450a26f659fc6a14c1cbb2003681972ba)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 65dba39450a26f659fc6a14c1cbb2003681972ba)" --date "$(git log -1 --format="%ad" 65dba39450a26f659fc6a14c1cbb2003681972ba)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 01197db6415951228286dde4cd3ebecc6297457e && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 01197db6415951228286dde4cd3ebecc6297457e)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 01197db6415951228286dde4cd3ebecc6297457e)" --date "$(git log -1 --format="%ad" 01197db6415951228286dde4cd3ebecc6297457e)" && unset GIT_COMMITTER_DATE
git cherry-pick -n f1346ce3f446e6a89f39748bf319949fb54036a3 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" f1346ce3f446e6a89f39748bf319949fb54036a3)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" f1346ce3f446e6a89f39748bf319949fb54036a3)" --date "$(git log -1 --format="%ad" f1346ce3f446e6a89f39748bf319949fb54036a3)" && unset GIT_COMMITTER_DATE
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/91/294291/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/86/333386/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/55/535255/1/*.patch`
cd ../display && repo start $GIT_BRANCH .
git revert --no-edit --no-commit 51b4299f42c61d3a919c8e86c38a85f40902226b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 51b4299f42c61d3a919c8e86c38a85f40902226b)" --date "$(git log -1 --format="%ad" 51b4299f42c61d3a919c8e86c38a85f40902226b)" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit b7d1a389b00370fc9d2a7db1268ce26271ead7e2 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" b7d1a389b00370fc9d2a7db1268ce26271ead7e2)" --date "$(git log -1 --format="%ad" b7d1a389b00370fc9d2a7db1268ce26271ead7e2)" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit f026d04dde743a0524235ae57e2ce8ac5364d44b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" f026d04dde743a0524235ae57e2ce8ac5364d44b)" --date "$(git log -1 --format="%ad" f026d04dde743a0524235ae57e2ce8ac5364d44b)" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit 3261eb2236252f9f2510c008fad451411a780b3b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 3261eb2236252f9f2510c008fad451411a780b3b)" --date "$(git log -1 --format="%ad" 3261eb2236252f9f2510c008fad451411a780b3b)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 05b2a3cf90e4b2d82e713e5cb13b165215ee42e6 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 05b2a3cf90e4b2d82e713e5cb13b165215ee42e6)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 05b2a3cf90e4b2d82e713e5cb13b165215ee42e6)" --date "$(git log -1 --format="%ad" 05b2a3cf90e4b2d82e713e5cb13b165215ee42e6)" && unset GIT_COMMITTER_DATE
git cherry-pick -n eb58d55cd4aa3010d6e9e5d8f19d36869b369805 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" eb58d55cd4aa3010d6e9e5d8f19d36869b369805)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" eb58d55cd4aa3010d6e9e5d8f19d36869b369805)" --date "$(git log -1 --format="%ad" eb58d55cd4aa3010d6e9e5d8f19d36869b369805)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 72adb432f6bdb99433ebb261d8e55395d10783de && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 72adb432f6bdb99433ebb261d8e55395d10783de)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 72adb432f6bdb99433ebb261d8e55395d10783de)" --date "$(git log -1 --format="%ad" 72adb432f6bdb99433ebb261d8e55395d10783de)" && unset GIT_COMMITTER_DATE
git cherry-pick -n a558e9f988d654c776a1aa093fef1e2b4fc96ede && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" a558e9f988d654c776a1aa093fef1e2b4fc96ede)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" a558e9f988d654c776a1aa093fef1e2b4fc96ede)" --date "$(git log -1 --format="%ad" a558e9f988d654c776a1aa093fef1e2b4fc96ede)" && unset GIT_COMMITTER_DATE
git cherry-pick -n d62c8a289ff6b4838e543e82b655dc436f387574 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" d62c8a289ff6b4838e543e82b655dc436f387574)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" d62c8a289ff6b4838e543e82b655dc436f387574)" --date "$(git log -1 --format="%ad" d62c8a289ff6b4838e543e82b655dc436f387574)" && unset GIT_COMMITTER_DATE
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/54/274454/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/55/274455/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/35/437235/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/36/437236/1/*.patch`
cd ../media && repo start $GIT_BRANCH .
git cherry-pick -n 69b56682975340fc17ce9eac3cefd2d6c5bfdd84 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 69b56682975340fc17ce9eac3cefd2d6c5bfdd84)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 69b56682975340fc17ce9eac3cefd2d6c5bfdd84)" --date "$(git log -1 --format="%ad" 69b56682975340fc17ce9eac3cefd2d6c5bfdd84)" && unset GIT_COMMITTER_DATE
git cherry-pick -n fa202b9b18f17f7835fd602db5fff530e61112b4 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" fa202b9b18f17f7835fd602db5fff530e61112b4)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" fa202b9b18f17f7835fd602db5fff530e61112b4)" --date "$(git log -1 --format="%ad" fa202b9b18f17f7835fd602db5fff530e61112b4)" && unset GIT_COMMITTER_DATE
git cherry-pick -n b50ee0d49e33884a5f998649944fff0a8e27cda6 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" b50ee0d49e33884a5f998649944fff0a8e27cda6)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" b50ee0d49e33884a5f998649944fff0a8e27cda6)" --date "$(git log -1 --format="%ad" b50ee0d49e33884a5f998649944fff0a8e27cda6)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 0cfe6f8bff87bcbdeef6fcfdbb91d67d42f33927 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 0cfe6f8bff87bcbdeef6fcfdbb91d67d42f33927)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 0cfe6f8bff87bcbdeef6fcfdbb91d67d42f33927)" --date "$(git log -1 --format="%ad" 0cfe6f8bff87bcbdeef6fcfdbb91d67d42f33927)" && unset GIT_COMMITTER_DATE
git cherry-pick -n af7f1cd76eaafee0d9838e6c40af9c494e884e36 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" af7f1cd76eaafee0d9838e6c40af9c494e884e36)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" af7f1cd76eaafee0d9838e6c40af9c494e884e36)" --date "$(git log -1 --format="%ad" af7f1cd76eaafee0d9838e6c40af9c494e884e36)" && unset GIT_COMMITTER_DATE
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/media/refs/changes/39/422439/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/media/refs/changes/79/422379/1/*.patch`
cd ../gps && repo start $GIT_BRANCH .
git cherry-pick -n bc2807add2c6d891258fdf5794c38ee2429a7b3e && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" bc2807add2c6d891258fdf5794c38ee2429a7b3e)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" bc2807add2c6d891258fdf5794c38ee2429a7b3e)" --date "$(git log -1 --format="%ad" bc2807add2c6d891258fdf5794c38ee2429a7b3e)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 63f8eb733a0dd9b2c3a0ae282e5c8b1adde7ef16 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 63f8eb733a0dd9b2c3a0ae282e5c8b1adde7ef16)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 63f8eb733a0dd9b2c3a0ae282e5c8b1adde7ef16)" --date "$(git log -1 --format="%ad" 63f8eb733a0dd9b2c3a0ae282e5c8b1adde7ef16)" && unset GIT_COMMITTER_DATE
git cherry-pick -n c5b4bd379426c4f32a7afcacf08ee92271f7a4ba && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" c5b4bd379426c4f32a7afcacf08ee92271f7a4ba)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" c5b4bd379426c4f32a7afcacf08ee92271f7a4ba)" --date "$(git log -1 --format="%ad" c5b4bd379426c4f32a7afcacf08ee92271f7a4ba)" && unset GIT_COMMITTER_DATE
git cherry-pick -n c2fbb41f698d238de6a6a66111e700a73823936e && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" c2fbb41f698d238de6a6a66111e700a73823936e)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" c2fbb41f698d238de6a6a66111e700a73823936e)" --date "$(git log -1 --format="%ad" c2fbb41f698d238de6a6a66111e700a73823936e)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 02f13da8e1d303f5b7ccbe21633e6d0cb6331868 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 02f13da8e1d303f5b7ccbe21633e6d0cb6331868)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 02f13da8e1d303f5b7ccbe21633e6d0cb6331868)" --date "$(git log -1 --format="%ad" 02f13da8e1d303f5b7ccbe21633e6d0cb6331868)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 4eda8e1eabead3a9115bdd9cedd7e336ed431dbe && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 4eda8e1eabead3a9115bdd9cedd7e336ed431dbe)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 4eda8e1eabead3a9115bdd9cedd7e336ed431dbe)" --date "$(git log -1 --format="%ad" 4eda8e1eabead3a9115bdd9cedd7e336ed431dbe)" && unset GIT_COMMITTER_DATE
cd ../keymaster && repo start $GIT_BRANCH .
git revert --no-edit --no-commit 583ecf5ed2a4be0d05229b8c6726680c3836be8b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 583ecf5ed2a4be0d05229b8c6726680c3836be8b)" --date "$(git log -1 --format="%ad" 583ecf5ed2a4be0d05229b8c6726680c3836be8b)" && unset GIT_COMMITTER_DATE
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/70/212570/5/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/80/212580/2/*.patch`
cd ../../../system/core && repo start $GIT_BRANCH .
git cherry-pick -n 0ee524de689e27379eaa3d0af0152183b844b0e8 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 0ee524de689e27379eaa3d0af0152183b844b0e8)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 0ee524de689e27379eaa3d0af0152183b844b0e8)" --date "$(git log -1 --format="%ad" 0ee524de689e27379eaa3d0af0152183b844b0e8)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 565ba02b89b64deb8bf7232ac2c2a38b01f63523 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 565ba02b89b64deb8bf7232ac2c2a38b01f63523)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 565ba02b89b64deb8bf7232ac2c2a38b01f63523)" --date "$(git log -1 --format="%ad" 565ba02b89b64deb8bf7232ac2c2a38b01f63523)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 3f0250c3cc84b2480ef70d51343204eecbe84532 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 3f0250c3cc84b2480ef70d51343204eecbe84532)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 3f0250c3cc84b2480ef70d51343204eecbe84532)" --date "$(git log -1 --format="%ad" 3f0250c3cc84b2480ef70d51343204eecbe84532)" && unset GIT_COMMITTER_DATE
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
