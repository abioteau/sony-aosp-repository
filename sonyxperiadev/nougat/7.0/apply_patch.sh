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
~/bin/repo init -u $AOSP_MIRROR_URL/platform/manifest.git --repo-url $REPO_MIRROR_URL/git-repo.git -b android-7.0.0_r34

sed -i -e "/^  <!-- Sony AOSP addons -->/d; /^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n\1/" .repo/manifests/default.xml
git clone $GITHUB_MIRROR_URL/abioteau/local_manifests
cd local_manifests
git checkout -f n-mr0
sed -i "s/fetch=\".*:\/\/github.com\/\(.*\)\"/fetch=\"$(echo $GITHUB_MIRROR_REL_URL | sed 's/\//\\\//g')\/\1\"/" *.xml
find *.xml | xargs -I {} sed -i -e "/^  <include name=\"{}\"\/>/d; /^<\/manifest/ s/\(.*\)/  <include name=\"{}\"\/>\n\1/" ../.repo/manifests/default.xml
cp *.xml ../.repo/manifests/.
cd ..
rm -rf local_manifests

~/bin/repo sync -j $NB_CORES
~/bin/repo manifest -o manifest.xml -r

cd external/toybox && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/toybox/refs/changes/74/265074/1/*.patch`
git cherry-pick -n d3e8dd1bf56afc2277960472a46907d419e4b3da && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" d3e8dd1bf56afc2277960472a46907d419e4b3da)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" d3e8dd1bf56afc2277960472a46907d419e4b3da)" --date "$(git log -1 --format="%ad" d3e8dd1bf56afc2277960472a46907d419e4b3da)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 1c028ca33dc059a9d8f18daafcd77b5950268f41 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 1c028ca33dc059a9d8f18daafcd77b5950268f41)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 1c028ca33dc059a9d8f18daafcd77b5950268f41)" --date "$(git log -1 --format="%ad" 1c028ca33dc059a9d8f18daafcd77b5950268f41)" && unset GIT_COMMITTER_DATE
git cherry-pick -n cb49c305e3c78179b19d6f174ae73309544292b8 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" cb49c305e3c78179b19d6f174ae73309544292b8)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" cb49c305e3c78179b19d6f174ae73309544292b8)" --date "$(git log -1 --format="%ad" cb49c305e3c78179b19d6f174ae73309544292b8)" && unset GIT_COMMITTER_DATE
cd ../../hardware/qcom/audio && repo start $GIT_BRANCH .
git cherry-pick -n 1d2e4743ffcbd27ed2e96c1c8ac1e186a717fa45 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 1d2e4743ffcbd27ed2e96c1c8ac1e186a717fa45)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 1d2e4743ffcbd27ed2e96c1c8ac1e186a717fa45)" --date "$(git log -1 --format="%ad" 1d2e4743ffcbd27ed2e96c1c8ac1e186a717fa45)" && unset GIT_COMMITTER_DATE
git cherry-pick -n a8d7c9257c3c9514f5c35d3dbd987703e12c82cd && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" a8d7c9257c3c9514f5c35d3dbd987703e12c82cd)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" a8d7c9257c3c9514f5c35d3dbd987703e12c82cd)" --date "$(git log -1 --format="%ad" a8d7c9257c3c9514f5c35d3dbd987703e12c82cd)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 6b4b127cad4dce4db30c5119d8fd6bbc0af3924c && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 6b4b127cad4dce4db30c5119d8fd6bbc0af3924c)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 6b4b127cad4dce4db30c5119d8fd6bbc0af3924c)" --date "$(git log -1 --format="%ad" 6b4b127cad4dce4db30c5119d8fd6bbc0af3924c)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 9ebf582bd7f0b701f969081646d27c4a77347402 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 9ebf582bd7f0b701f969081646d27c4a77347402)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 9ebf582bd7f0b701f969081646d27c4a77347402)" --date "$(git log -1 --format="%ad" 9ebf582bd7f0b701f969081646d27c4a77347402)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 536daa591913c5eaf3fea47c90a5cf4bc24ce321 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 536daa591913c5eaf3fea47c90a5cf4bc24ce321)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 536daa591913c5eaf3fea47c90a5cf4bc24ce321)" --date "$(git log -1 --format="%ad" 536daa591913c5eaf3fea47c90a5cf4bc24ce321)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 152b09a14f3b2c17063468b3f5b5ddda195802ec && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 152b09a14f3b2c17063468b3f5b5ddda195802ec)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 152b09a14f3b2c17063468b3f5b5ddda195802ec)" --date "$(git log -1 --format="%ad" 152b09a14f3b2c17063468b3f5b5ddda195802ec)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 6ebefdd83d29132f6ca5a5d6b45cac71871dd037 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 6ebefdd83d29132f6ca5a5d6b45cac71871dd037)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 6ebefdd83d29132f6ca5a5d6b45cac71871dd037)" --date "$(git log -1 --format="%ad" 6ebefdd83d29132f6ca5a5d6b45cac71871dd037)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 56631b51985194269339dbf53316f414b3d21050 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 56631b51985194269339dbf53316f414b3d21050)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 56631b51985194269339dbf53316f414b3d21050)" --date "$(git log -1 --format="%ad" 56631b51985194269339dbf53316f414b3d21050)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 2d809e0d104497ca6b7a1e1be4efdf7856070aa5 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 2d809e0d104497ca6b7a1e1be4efdf7856070aa5)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 2d809e0d104497ca6b7a1e1be4efdf7856070aa5)" --date "$(git log -1 --format="%ad" 2d809e0d104497ca6b7a1e1be4efdf7856070aa5)" && unset GIT_COMMITTER_DATE
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/35/274235/6/*.patch`
cd ../bt && repo start $GIT_BRANCH .
git revert --no-edit --no-commit c7dc913784965e4ce705c2045f0a8b43fcd1db1c && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" c7dc913784965e4ce705c2045f0a8b43fcd1db1c)" --date "$(git log -1 --format="%ad" c7dc913784965e4ce705c2045f0a8b43fcd1db1c)" && unset GIT_COMMITTER_DATE
cd ../display && repo start $GIT_BRANCH .
git revert --no-edit --no-commit b7d1a389b00370fc9d2a7db1268ce26271ead7e2 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" b7d1a389b00370fc9d2a7db1268ce26271ead7e2)" --date "$(git log -1 --format="%ad" b7d1a389b00370fc9d2a7db1268ce26271ead7e2)" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit f026d04dde743a0524235ae57e2ce8ac5364d44b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" f026d04dde743a0524235ae57e2ce8ac5364d44b)" --date "$(git log -1 --format="%ad" f026d04dde743a0524235ae57e2ce8ac5364d44b)" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit 3261eb2236252f9f2510c008fad451411a780b3b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 3261eb2236252f9f2510c008fad451411a780b3b)" --date "$(git log -1 --format="%ad" 3261eb2236252f9f2510c008fad451411a780b3b)" && unset GIT_COMMITTER_DATE
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/72/265072/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/73/265073/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/54/274454/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/55/274455/1/*.patch`
cd ../gps && repo start $GIT_BRANCH .
git revert --no-edit --no-commit 53bf15aab71461f81e27e6f5176afcd1a29af7d4 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 53bf15aab71461f81e27e6f5176afcd1a29af7d4)" --date "$(git log -1 --format="%ad" 53bf15aab71461f81e27e6f5176afcd1a29af7d4)" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit 486ab751599b7f8b5a2f2711d22867ad54fdc79b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 486ab751599b7f8b5a2f2711d22867ad54fdc79b)" --date "$(git log -1 --format="%ad" 486ab751599b7f8b5a2f2711d22867ad54fdc79b)" && unset GIT_COMMITTER_DATE
cd ../media && repo start $GIT_BRANCH .
git revert --no-edit --no-commit 9e8b76d32ece15e79ebf4b02ede869d89807eec6 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 9e8b76d32ece15e79ebf4b02ede869d89807eec6)" --date "$(git log -1 --format="%ad" 9e8b76d32ece15e79ebf4b02ede869d89807eec6)" && unset GIT_COMMITTER_DATE
cd ../keymaster && repo start $GIT_BRANCH .
git revert --no-edit --no-commit 583ecf5ed2a4be0d05229b8c6726680c3836be8b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 583ecf5ed2a4be0d05229b8c6726680c3836be8b)" --date "$(git log -1 --format="%ad" 583ecf5ed2a4be0d05229b8c6726680c3836be8b)" && unset GIT_COMMITTER_DATE
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/70/212570/5/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/80/212580/2/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/61/213261/1/*.patch`
cd ../../../system/core && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/52/269652/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/58/327458/1/*.patch`
cd ../../packages/apps/Nfc && repo start $GIT_BRANCH .
git revert --no-edit --no-commit 988c3fff5470a1de3a880bd07fa438cc47e283c8 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 988c3fff5470a1de3a880bd07fa438cc47e283c8)" --date "$(git log -1 --format="%ad" 988c3fff5470a1de3a880bd07fa438cc47e283c8)" && unset GIT_COMMITTER_DATE
cd ../Music && repo start $GIT_BRANCH .
git cherry-pick -n 6036ce6127022880a3d9c99bd15db4c968f3e6a3 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 6036ce6127022880a3d9c99bd15db4c968f3e6a3)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 6036ce6127022880a3d9c99bd15db4c968f3e6a3)" --date "$(git log -1 --format="%ad" 6036ce6127022880a3d9c99bd15db4c968f3e6a3)" && unset GIT_COMMITTER_DATE
cd ../../../frameworks/av && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/av/refs/changes/71/316171/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/av/refs/changes/72/316172/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/av/refs/changes/73/316173/1/*.patch`
cd ../..



cd $ROOTDIR
