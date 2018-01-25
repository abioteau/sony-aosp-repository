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
~/bin/repo init -u $AOSP_MIRROR_URL/platform/manifest.git --repo-url $REPO_MIRROR_URL/git-repo.git -b android-7.1.1_r55

sed -i -e "/^  <!-- Sony AOSP addons -->/d; /^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n\1/" .repo/manifests/default.xml
git clone $GITHUB_MIRROR_URL/abioteau/local_manifests
cd local_manifests
git checkout -f n-mr1_4.4
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
git format-patch -o /tmp/35fff61b1c0d736d090a1cd1bb4e99141cc88ad8 -1 35fff61b1c0d736d090a1cd1bb4e99141cc88ad8 && git am -3 --committer-date-is-author-date /tmp/35fff61b1c0d736d090a1cd1bb4e99141cc88ad8/0001-*.patch && rm -rf /tmp/35fff61b1c0d736d090a1cd1bb4e99141cc88ad8
git format-patch -o /tmp/d00f5eb63a8e4690f9bef1e943d539d052444d9b -1 d00f5eb63a8e4690f9bef1e943d539d052444d9b && git am -3 --committer-date-is-author-date /tmp/d00f5eb63a8e4690f9bef1e943d539d052444d9b/0001-*.patch && rm -rf /tmp/d00f5eb63a8e4690f9bef1e943d539d052444d9b
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/bootable/recovery/refs/changes/15/538015/2/*.patch`
cd ../../external/toybox && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/toybox/refs/changes/74/265074/1/*.patch`
git format-patch -o /tmp/d3e8dd1bf56afc2277960472a46907d419e4b3da -1 d3e8dd1bf56afc2277960472a46907d419e4b3da && git am -3 --committer-date-is-author-date /tmp/d3e8dd1bf56afc2277960472a46907d419e4b3da/0001-*.patch && rm -rf /tmp/d3e8dd1bf56afc2277960472a46907d419e4b3da
git format-patch -o /tmp/1c028ca33dc059a9d8f18daafcd77b5950268f41 -1 1c028ca33dc059a9d8f18daafcd77b5950268f41 && git am -3 --committer-date-is-author-date /tmp/1c028ca33dc059a9d8f18daafcd77b5950268f41/0001-*.patch && rm -rf /tmp/1c028ca33dc059a9d8f18daafcd77b5950268f41
git format-patch -o /tmp/cb49c305e3c78179b19d6f174ae73309544292b8 -1 cb49c305e3c78179b19d6f174ae73309544292b8 && git am -3 --committer-date-is-author-date /tmp/cb49c305e3c78179b19d6f174ae73309544292b8/0001-*.patch && rm -rf /tmp/cb49c305e3c78179b19d6f174ae73309544292b8
cd ../iproute2 && repo start $GIT_BRANCH .
git format-patch -o /tmp/04cd308001d732a1c8e5d244daba37c56a4641b0 -1 04cd308001d732a1c8e5d244daba37c56a4641b0 && git am -3 --committer-date-is-author-date /tmp/04cd308001d732a1c8e5d244daba37c56a4641b0/0001-*.patch && rm -rf /tmp/04cd308001d732a1c8e5d244daba37c56a4641b0
cd ../libnfc-nci && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/libnfc-nci/refs/changes/52/371052/1/*.patch`
cd ../../hardware/qcom/bt && repo start $GIT_BRANCH .
git format-patch -o /tmp/9340e065671f2defd5be2a4aac616a15b2c584c6 -1 9340e065671f2defd5be2a4aac616a15b2c584c6 && git am -3 --committer-date-is-author-date /tmp/9340e065671f2defd5be2a4aac616a15b2c584c6/0001-*.patch && rm -rf /tmp/9340e065671f2defd5be2a4aac616a15b2c584c6
git format-patch -o /tmp/6572a3ba8186fc719c0f81de8820fb8d3009d0a0 -1 6572a3ba8186fc719c0f81de8820fb8d3009d0a0 && git am -3 --committer-date-is-author-date /tmp/6572a3ba8186fc719c0f81de8820fb8d3009d0a0/0001-*.patch && rm -rf /tmp/6572a3ba8186fc719c0f81de8820fb8d3009d0a0
git format-patch -o /tmp/661a4bab919e4761e2b782474badb19f14ce3388 -1 661a4bab919e4761e2b782474badb19f14ce3388 && git am -3 --committer-date-is-author-date /tmp/661a4bab919e4761e2b782474badb19f14ce3388/0001-*.patch && rm -rf /tmp/661a4bab919e4761e2b782474badb19f14ce3388
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/bt/refs/changes/99/422499/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/bt/refs/changes/00/422500/1/*.patch`
cd ../audio && repo start $GIT_BRANCH .
git format-patch -o /tmp/0cfc50a503fb058011b7fef517488f6df4c419e5 -1 0cfc50a503fb058011b7fef517488f6df4c419e5 && git am -3 --committer-date-is-author-date /tmp/0cfc50a503fb058011b7fef517488f6df4c419e5/0001-*.patch && rm -rf /tmp/0cfc50a503fb058011b7fef517488f6df4c419e5
git format-patch -o /tmp/8a8deaa00035aa29968201eadbc9fe32eb5ad675 -1 8a8deaa00035aa29968201eadbc9fe32eb5ad675 && git am -3 --committer-date-is-author-date /tmp/8a8deaa00035aa29968201eadbc9fe32eb5ad675/0001-*.patch && rm -rf /tmp/8a8deaa00035aa29968201eadbc9fe32eb5ad675
git format-patch -o /tmp/65dba39450a26f659fc6a14c1cbb2003681972ba -1 65dba39450a26f659fc6a14c1cbb2003681972ba && git am -3 --committer-date-is-author-date /tmp/65dba39450a26f659fc6a14c1cbb2003681972ba/0001-*.patch && rm -rf /tmp/65dba39450a26f659fc6a14c1cbb2003681972ba
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/91/294291/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/35/274235/9/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/86/333386/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/55/535255/1/*.patch`
cd ../display && repo start $GIT_BRANCH .
git revert --no-edit --no-commit 51b4299f42c61d3a919c8e86c38a85f40902226b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit -m "`cat .git/MERGE_MSG`" --author "`git log -1 51b4299f42c61d3a919c8e86c38a85f40902226b | grep "Author: " | sed -e "s/Author: //"`" --date "`git log -1 51b4299f42c61d3a919c8e86c38a85f40902226b | grep "Date:   " | sed -e "s/Date:   //"`" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit b7d1a389b00370fc9d2a7db1268ce26271ead7e2 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit -m "`cat .git/MERGE_MSG`" --author "`git log -1 b7d1a389b00370fc9d2a7db1268ce26271ead7e2 | grep "Author: " | sed -e "s/Author: //"`" --date "`git log -1 b7d1a389b00370fc9d2a7db1268ce26271ead7e2 | grep "Date:   " | sed -e "s/Date:   //"`" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit f026d04dde743a0524235ae57e2ce8ac5364d44b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit -m "`cat .git/MERGE_MSG`" --author "`git log -1 f026d04dde743a0524235ae57e2ce8ac5364d44b | grep "Author: " | sed -e "s/Author: //"`" --date "`git log -1 f026d04dde743a0524235ae57e2ce8ac5364d44b | grep "Date:   " | sed -e "s/Date:   //"`" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit 3261eb2236252f9f2510c008fad451411a780b3b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit -m "`cat .git/MERGE_MSG`" --author "`git log -1 3261eb2236252f9f2510c008fad451411a780b3b | grep "Author: " | sed -e "s/Author: //"`" --date "`git log -1 3261eb2236252f9f2510c008fad451411a780b3b | grep "Date:   " | sed -e "s/Date:   //"`" && unset GIT_COMMITTER_DATE
git format-patch -o /tmp/05b2a3cf90e4b2d82e713e5cb13b165215ee42e6 -1 05b2a3cf90e4b2d82e713e5cb13b165215ee42e6 && git am -3 --committer-date-is-author-date /tmp/05b2a3cf90e4b2d82e713e5cb13b165215ee42e6/0001-*.patch && rm -rf /tmp/05b2a3cf90e4b2d82e713e5cb13b165215ee42e6
git format-patch -o /tmp/eb58d55cd4aa3010d6e9e5d8f19d36869b369805 -1 eb58d55cd4aa3010d6e9e5d8f19d36869b369805 && git am -3 --committer-date-is-author-date /tmp/eb58d55cd4aa3010d6e9e5d8f19d36869b369805/0001-*.patch && rm -rf /tmp/eb58d55cd4aa3010d6e9e5d8f19d36869b369805
git format-patch -o /tmp/72adb432f6bdb99433ebb261d8e55395d10783de -1 72adb432f6bdb99433ebb261d8e55395d10783de && git am -3 --committer-date-is-author-date /tmp/72adb432f6bdb99433ebb261d8e55395d10783de/0001-*.patch && rm -rf /tmp/72adb432f6bdb99433ebb261d8e55395d10783de
git format-patch -o /tmp/a558e9f988d654c776a1aa093fef1e2b4fc96ede -1 a558e9f988d654c776a1aa093fef1e2b4fc96ede && git am -3 --committer-date-is-author-date /tmp/a558e9f988d654c776a1aa093fef1e2b4fc96ede/0001-*.patch && rm -rf /tmp/a558e9f988d654c776a1aa093fef1e2b4fc96ede
git format-patch -o /tmp/d62c8a289ff6b4838e543e82b655dc436f387574 -1 d62c8a289ff6b4838e543e82b655dc436f387574 && git am -3 --committer-date-is-author-date /tmp/d62c8a289ff6b4838e543e82b655dc436f387574/0001-*.patch && rm -rf /tmp/d62c8a289ff6b4838e543e82b655dc436f387574
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/54/274454/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/55/274455/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/35/437235/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/36/437236/1/*.patch`
cd ../media && repo start $GIT_BRANCH .
git format-patch -o /tmp/69b56682975340fc17ce9eac3cefd2d6c5bfdd84 -1 69b56682975340fc17ce9eac3cefd2d6c5bfdd84 && git am -3 --committer-date-is-author-date /tmp/69b56682975340fc17ce9eac3cefd2d6c5bfdd84/0001-*.patch && rm -rf /tmp/69b56682975340fc17ce9eac3cefd2d6c5bfdd84
git format-patch -o /tmp/fa202b9b18f17f7835fd602db5fff530e61112b4 -1 fa202b9b18f17f7835fd602db5fff530e61112b4 && git am -3 --committer-date-is-author-date /tmp/fa202b9b18f17f7835fd602db5fff530e61112b4/0001-*.patch && rm -rf /tmp/fa202b9b18f17f7835fd602db5fff530e61112b4
git format-patch -o /tmp/b50ee0d49e33884a5f998649944fff0a8e27cda6 -1 b50ee0d49e33884a5f998649944fff0a8e27cda6 && git am -3 --committer-date-is-author-date /tmp/b50ee0d49e33884a5f998649944fff0a8e27cda6/0001-*.patch && rm -rf /tmp/b50ee0d49e33884a5f998649944fff0a8e27cda6
git format-patch -o /tmp/0cfe6f8bff87bcbdeef6fcfdbb91d67d42f33927 -1 0cfe6f8bff87bcbdeef6fcfdbb91d67d42f33927 && git am -3 --committer-date-is-author-date /tmp/0cfe6f8bff87bcbdeef6fcfdbb91d67d42f33927/0001-*.patch && rm -rf /tmp/0cfe6f8bff87bcbdeef6fcfdbb91d67d42f33927
git format-patch -o /tmp/af7f1cd76eaafee0d9838e6c40af9c494e884e36 -1 af7f1cd76eaafee0d9838e6c40af9c494e884e36 && git am -3 --committer-date-is-author-date /tmp/af7f1cd76eaafee0d9838e6c40af9c494e884e36/0001-*.patch && rm -rf /tmp/af7f1cd76eaafee0d9838e6c40af9c494e884e36
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/media/refs/changes/39/422439/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/media/refs/changes/79/422379/1/*.patch`
cd ../gps && repo start $GIT_BRANCH .
git format-patch -o /tmp/02f13da8e1d303f5b7ccbe21633e6d0cb6331868 -1 02f13da8e1d303f5b7ccbe21633e6d0cb6331868 && git am -3 --committer-date-is-author-date /tmp/02f13da8e1d303f5b7ccbe21633e6d0cb6331868/0001-*.patch && rm -rf /tmp/02f13da8e1d303f5b7ccbe21633e6d0cb6331868
git format-patch -o /tmp/4eda8e1eabead3a9115bdd9cedd7e336ed431dbe -1 4eda8e1eabead3a9115bdd9cedd7e336ed431dbe && git am -3 --committer-date-is-author-date /tmp/4eda8e1eabead3a9115bdd9cedd7e336ed431dbe/0001-*.patch && rm -rf /tmp/4eda8e1eabead3a9115bdd9cedd7e336ed431dbe
cd ../keymaster && repo start $GIT_BRANCH .
git revert --no-edit --no-commit 583ecf5ed2a4be0d05229b8c6726680c3836be8b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit -m "`cat .git/MERGE_MSG`" --author "`git log -1 583ecf5ed2a4be0d05229b8c6726680c3836be8b | grep "Author: " | sed -e "s/Author: //"`" --date "`git log -1 583ecf5ed2a4be0d05229b8c6726680c3836be8b | grep "Date:   " | sed -e "s/Date:   //"`" && unset GIT_COMMITTER_DATE
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/70/212570/5/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/80/212580/2/*.patch`
cd ../../../system/core && repo start $GIT_BRANCH .
git format-patch -o /tmp/0ee524de689e27379eaa3d0af0152183b844b0e8 -1 0ee524de689e27379eaa3d0af0152183b844b0e8 && git am -3 --committer-date-is-author-date /tmp/0ee524de689e27379eaa3d0af0152183b844b0e8/0001-*.patch && rm -rf /tmp/0ee524de689e27379eaa3d0af0152183b844b0e8
git format-patch -o /tmp/565ba02b89b64deb8bf7232ac2c2a38b01f63523 -1 565ba02b89b64deb8bf7232ac2c2a38b01f63523 && git am -3 --committer-date-is-author-date /tmp/565ba02b89b64deb8bf7232ac2c2a38b01f63523/0001-*.patch && rm -rf /tmp/565ba02b89b64deb8bf7232ac2c2a38b01f63523
git format-patch -o /tmp/3f0250c3cc84b2480ef70d51343204eecbe84532 -1 3f0250c3cc84b2480ef70d51343204eecbe84532 && git am -3 --committer-date-is-author-date /tmp/3f0250c3cc84b2480ef70d51343204eecbe84532/0001-*.patch && rm -rf /tmp/3f0250c3cc84b2480ef70d51343204eecbe84532
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/52/269652/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/12/373812/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/75/537175/1/*.patch`
cd ../extras && repo start $GIT_BRANCH .
git format-patch -o /tmp/c71eaf37486bed9163ad528f51de29dd56b34fd2 -1 c71eaf37486bed9163ad528f51de29dd56b34fd2 && git am -3 --committer-date-is-author-date /tmp/c71eaf37486bed9163ad528f51de29dd56b34fd2/0001-*.patch && rm -rf /tmp/c71eaf37486bed9163ad528f51de29dd56b34fd2
cd ../netd && repo start $GIT_BRANCH .
git format-patch -o /tmp/2b078678aafceeefea6a70e96ab8ddefe515d027 -1 2b078678aafceeefea6a70e96ab8ddefe515d027 && git am -3 --committer-date-is-author-date /tmp/2b078678aafceeefea6a70e96ab8ddefe515d027/0001-*.patch && rm -rf /tmp/2b078678aafceeefea6a70e96ab8ddefe515d027
git format-patch -o /tmp/882e467ff7b83de868fa0b9a9beb9036bf14aede -1 882e467ff7b83de868fa0b9a9beb9036bf14aede && git am -3 --committer-date-is-author-date /tmp/882e467ff7b83de868fa0b9a9beb9036bf14aede/0001-*.patch && rm -rf /tmp/882e467ff7b83de868fa0b9a9beb9036bf14aede
cd ../../packages/apps/Camera2 && repo start $GIT_BRANCH .
git format-patch -o /tmp/8b17de0f4321fd981da98c64ad8a379ed6c0432a -1 8b17de0f4321fd981da98c64ad8a379ed6c0432a && git am -3 --committer-date-is-author-date /tmp/8b17de0f4321fd981da98c64ad8a379ed6c0432a/0001-*.patch && rm -rf /tmp/8b17de0f4321fd981da98c64ad8a379ed6c0432a
cd ../Music && repo start $GIT_BRANCH .
git format-patch -o /tmp/6036ce6127022880a3d9c99bd15db4c968f3e6a3 -1 6036ce6127022880a3d9c99bd15db4c968f3e6a3 && git am -3 --committer-date-is-author-date /tmp/6036ce6127022880a3d9c99bd15db4c968f3e6a3/0001-*.patch && rm -rf /tmp/6036ce6127022880a3d9c99bd15db4c968f3e6a3
cd ../../../frameworks/av && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/av/refs/changes/69/343069/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/av/refs/changes/70/343070/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/av/refs/changes/71/343071/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/av/refs/changes/92/384692/2/*.patch`
cd ../../

cd $ROOTDIR
