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
~/bin/repo init -u $AOSP_MIRROR_URL/platform/manifest.git --repo-url $REPO_MIRROR_URL/git-repo.git -b android-8.0.0_r30

sed -i -e "/^  <!-- Sony AOSP addons -->/d; /^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n\1/" .repo/manifests/default.xml
git clone $GITHUB_MIRROR_URL/abioteau/local_manifests
cd local_manifests
git checkout -f android-8.0.0_r30
sed -i "s/fetch=\".*:\/\/github.com\/\(.*\)\"/fetch=\"$(echo $GITHUB_MIRROR_REL_URL | sed 's/\//\\\//g')\/\1\"/" *.xml
find *.xml | xargs -I {} sed -i -e "/^  <include name=\"{}\"\/>/d; /^<\/manifest/ s/\(.*\)/  <include name=\"{}\"\/>\n\1/" ../.repo/manifests/default.xml
cp *.xml ../.repo/manifests/.
cd ..
rm -rf local_manifests

~/bin/repo sync -j $NB_CORES
~/bin/repo manifest -o manifest.xml -r

cd bionic && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/bionic/refs/changes/53/363153/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/bionic/refs/changes/92/368092/2/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/bionic/refs/changes/14/265214/21/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/bionic/refs/changes/90/497890/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/bionic/refs/changes/91/497891/2/*.patch`
cd ../build/soong && repo start $GIT_BRANCH .
git revert --no-edit --no-commit 8cede07e698cc1a15257a6b5dd653488e2bbf49e && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 8cede07e698cc1a15257a6b5dd653488e2bbf49e)" --date "$(git log -1 --format="%ad" 8cede07e698cc1a15257a6b5dd653488e2bbf49e)" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit 0f1bd9d3d73f1d1a673c23d5b180172c8c4605db && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 0f1bd9d3d73f1d1a673c23d5b180172c8c4605db)" --date "$(git log -1 --format="%ad" 0f1bd9d3d73f1d1a673c23d5b180172c8c4605db)" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit e54d01029b8e2743254740a7a2ca167c6647e5d2 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" e54d01029b8e2743254740a7a2ca167c6647e5d2)" --date "$(git log -1 --format="%ad" e54d01029b8e2743254740a7a2ca167c6647e5d2)" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit 10b40b087cb9b7ead39da1e9fc6b7a85ecb4a901 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 10b40b087cb9b7ead39da1e9fc6b7a85ecb4a901)" --date "$(git log -1 --format="%ad" 10b40b087cb9b7ead39da1e9fc6b7a85ecb4a901)" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit 756b1c2343ed019ad59868c81491ea1eb7d42c57 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 756b1c2343ed019ad59868c81491ea1eb7d42c57)" --date "$(git log -1 --format="%ad" 756b1c2343ed019ad59868c81491ea1eb7d42c57)" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit 95421a4a776c5119d7d0729dd2efe05568d19f2b && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 95421a4a776c5119d7d0729dd2efe05568d19f2b)" --date "$(git log -1 --format="%ad" 95421a4a776c5119d7d0729dd2efe05568d19f2b)" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit 8ecfbadcc3fb1d1bd29a36e4e9dd6417399adaf3 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 8ecfbadcc3fb1d1bd29a36e4e9dd6417399adaf3)" --date "$(git log -1 --format="%ad" 8ecfbadcc3fb1d1bd29a36e4e9dd6417399adaf3)" && unset GIT_COMMITTER_DATE
git revert --no-edit --no-commit 0417699bbbd4151711e09925f3c72cbf3b8e81a5 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 0417699bbbd4151711e09925f3c72cbf3b8e81a5)" --date "$(git log -1 --format="%ad" 0417699bbbd4151711e09925f3c72cbf3b8e81a5)" && unset GIT_COMMITTER_DATE
git cherry-pick -n ae4fc1840653fd5598f81d33ac33a00d09b94607 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" ae4fc1840653fd5598f81d33ac33a00d09b94607)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" ae4fc1840653fd5598f81d33ac33a00d09b94607)" --date "$(git log -1 --format="%ad" ae4fc1840653fd5598f81d33ac33a00d09b94607)" && unset GIT_COMMITTER_DATE
git cherry-pick -n ac01ff5447518986f778be5b5c5a7bb0bf354e9c && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" ac01ff5447518986f778be5b5c5a7bb0bf354e9c)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" ac01ff5447518986f778be5b5c5a7bb0bf354e9c)" --date "$(git log -1 --format="%ad" ac01ff5447518986f778be5b5c5a7bb0bf354e9c)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 5df73d02ce2ccf373029ba082d5a1fac82dfa33e && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 5df73d02ce2ccf373029ba082d5a1fac82dfa33e)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 5df73d02ce2ccf373029ba082d5a1fac82dfa33e)" --date "$(git log -1 --format="%ad" 5df73d02ce2ccf373029ba082d5a1fac82dfa33e)" && unset GIT_COMMITTER_DATE
git cherry-pick -n b916b80bf301545595a8263776180c1db90a9ccc && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" b916b80bf301545595a8263776180c1db90a9ccc)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" b916b80bf301545595a8263776180c1db90a9ccc)" --date "$(git log -1 --format="%ad" b916b80bf301545595a8263776180c1db90a9ccc)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 1783a2f3e87ce191d5a22b0125aab6111a562a6c && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 1783a2f3e87ce191d5a22b0125aab6111a562a6c)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 1783a2f3e87ce191d5a22b0125aab6111a562a6c)" --date "$(git log -1 --format="%ad" 1783a2f3e87ce191d5a22b0125aab6111a562a6c)" && unset GIT_COMMITTER_DATE
git cherry-pick -n fff256f817213482c6b04ede2882aa9952d9948b && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" fff256f817213482c6b04ede2882aa9952d9948b)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" fff256f817213482c6b04ede2882aa9952d9948b)" --date "$(git log -1 --format="%ad" fff256f817213482c6b04ede2882aa9952d9948b)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 5cfd70952954ed5cffa270d9733df802123b1ea0 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 5cfd70952954ed5cffa270d9733df802123b1ea0)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 5cfd70952954ed5cffa270d9733df802123b1ea0)" --date "$(git log -1 --format="%ad" 5cfd70952954ed5cffa270d9733df802123b1ea0)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 0906f17f7e8bf0e76cb8511669e8fc8d5f6f3794 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 0906f17f7e8bf0e76cb8511669e8fc8d5f6f3794)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 0906f17f7e8bf0e76cb8511669e8fc8d5f6f3794)" --date "$(git log -1 --format="%ad" 0906f17f7e8bf0e76cb8511669e8fc8d5f6f3794)" && unset GIT_COMMITTER_DATE
git cherry-pick -n fa7e8af921afae02be39957c779bb11aa59f3699 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" fa7e8af921afae02be39957c779bb11aa59f3699)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" fa7e8af921afae02be39957c779bb11aa59f3699)" --date "$(git log -1 --format="%ad" fa7e8af921afae02be39957c779bb11aa59f3699)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 1d9aa26d445cd5407aea0831e6b67fb37dfc1d05 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 1d9aa26d445cd5407aea0831e6b67fb37dfc1d05)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 1d9aa26d445cd5407aea0831e6b67fb37dfc1d05)" --date "$(git log -1 --format="%ad" 1d9aa26d445cd5407aea0831e6b67fb37dfc1d05)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 5916657a96ce9fe90d2d2959472a8398f9ed7e58 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 5916657a96ce9fe90d2d2959472a8398f9ed7e58)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 5916657a96ce9fe90d2d2959472a8398f9ed7e58)" --date "$(git log -1 --format="%ad" 5916657a96ce9fe90d2d2959472a8398f9ed7e58)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 41f5d58cd5cb4ee5021ab1ad574342a1d19c5d3e && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 41f5d58cd5cb4ee5021ab1ad574342a1d19c5d3e)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 41f5d58cd5cb4ee5021ab1ad574342a1d19c5d3e)" --date "$(git log -1 --format="%ad" 41f5d58cd5cb4ee5021ab1ad574342a1d19c5d3e)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 8ecfbadcc3fb1d1bd29a36e4e9dd6417399adaf3 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 8ecfbadcc3fb1d1bd29a36e4e9dd6417399adaf3)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 8ecfbadcc3fb1d1bd29a36e4e9dd6417399adaf3)" --date "$(git log -1 --format="%ad" 8ecfbadcc3fb1d1bd29a36e4e9dd6417399adaf3)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 95421a4a776c5119d7d0729dd2efe05568d19f2b && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 95421a4a776c5119d7d0729dd2efe05568d19f2b)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 95421a4a776c5119d7d0729dd2efe05568d19f2b)" --date "$(git log -1 --format="%ad" 95421a4a776c5119d7d0729dd2efe05568d19f2b)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 756b1c2343ed019ad59868c81491ea1eb7d42c57 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 756b1c2343ed019ad59868c81491ea1eb7d42c57)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 756b1c2343ed019ad59868c81491ea1eb7d42c57)" --date "$(git log -1 --format="%ad" 756b1c2343ed019ad59868c81491ea1eb7d42c57)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 10b40b087cb9b7ead39da1e9fc6b7a85ecb4a901 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 10b40b087cb9b7ead39da1e9fc6b7a85ecb4a901)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 10b40b087cb9b7ead39da1e9fc6b7a85ecb4a901)" --date "$(git log -1 --format="%ad" 10b40b087cb9b7ead39da1e9fc6b7a85ecb4a901)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 0f1bd9d3d73f1d1a673c23d5b180172c8c4605db && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 0f1bd9d3d73f1d1a673c23d5b180172c8c4605db)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 0f1bd9d3d73f1d1a673c23d5b180172c8c4605db)" --date "$(git log -1 --format="%ad" 0f1bd9d3d73f1d1a673c23d5b180172c8c4605db)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 8cede07e698cc1a15257a6b5dd653488e2bbf49e && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 8cede07e698cc1a15257a6b5dd653488e2bbf49e)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 8cede07e698cc1a15257a6b5dd653488e2bbf49e)" --date "$(git log -1 --format="%ad" 8cede07e698cc1a15257a6b5dd653488e2bbf49e)" && unset GIT_COMMITTER_DATE
cd ../../bootable/recovery && repo start $GIT_BRANCH .
git cherry-pick -n 846012fc444e6076dabf874ed8cbdab358c2e0fb && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 846012fc444e6076dabf874ed8cbdab358c2e0fb)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 846012fc444e6076dabf874ed8cbdab358c2e0fb)" --date "$(git log -1 --format="%ad" 846012fc444e6076dabf874ed8cbdab358c2e0fb)" && unset GIT_COMMITTER_DATE
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/bootable/recovery/refs/changes/35/517735/2/*.patch`
cd ../../external/wpa_supplicant_8 && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/wpa_supplicant_8/refs/changes/00/512300/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/wpa_supplicant_8/refs/changes/01/512301/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/wpa_supplicant_8/refs/changes/02/512302/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/wpa_supplicant_8/refs/changes/03/512303/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/wpa_supplicant_8/refs/changes/04/512304/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/wpa_supplicant_8/refs/changes/05/512305/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/wpa_supplicant_8/refs/changes/06/512306/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/wpa_supplicant_8/refs/changes/07/512307/1/*.patch`
cd ../../hardware/qcom/gps && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/gps/refs/changes/37/464137/1/*.patch`
git cherry-pick -n 2804ee1ebc305ae91f95b3411cc70da69ae2635d && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 2804ee1ebc305ae91f95b3411cc70da69ae2635d)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 2804ee1ebc305ae91f95b3411cc70da69ae2635d)" --date "$(git log -1 --format="%ad" 2804ee1ebc305ae91f95b3411cc70da69ae2635d)" && unset GIT_COMMITTER_DATE
git cherry-pick -n 305b9daae60215de907f2e4913a20e02fd2b0c70 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" 305b9daae60215de907f2e4913a20e02fd2b0c70)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" 305b9daae60215de907f2e4913a20e02fd2b0c70)" --date "$(git log -1 --format="%ad" 305b9daae60215de907f2e4913a20e02fd2b0c70)" && unset GIT_COMMITTER_DATE
cd ../audio && repo start $GIT_BRANCH .
git cherry-pick -n f6aae037da61d2ec5327e157c0489dec1231f5c2 && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" f6aae037da61d2ec5327e157c0489dec1231f5c2)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" f6aae037da61d2ec5327e157c0489dec1231f5c2)" --date "$(git log -1 --format="%ad" f6aae037da61d2ec5327e157c0489dec1231f5c2)" && unset GIT_COMMITTER_DATE
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/91/294291/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/63/573163/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/56/535256/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/43/576643/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/41/602841/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/42/602842/1/*.patch`
cd ../media && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/media/refs/changes/39/422439/2/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/media/refs/changes/55/522855/1/*.patch`
cd ../display && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/35/437235/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/36/437236/1/*.patch`
cd ../bt && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/bt/refs/changes/17/478117/1/*.patch`
cd ../../../system/core && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/37/469437/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/92/497892/2/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/75/537175/1/*.patch`
git cherry-pick -n d266d37e4cb6d0b31eb9422b73f051632ea7365f && export GIT_COMMITTER_DATE="$(git log -1 --format="%ad" d266d37e4cb6d0b31eb9422b73f051632ea7365f)" && git commit --no-edit --author "$(git log -1 --format="%an <%ae>" d266d37e4cb6d0b31eb9422b73f051632ea7365f)" --date "$(git log -1 --format="%ad" d266d37e4cb6d0b31eb9422b73f051632ea7365f)" && unset GIT_COMMITTER_DATE
cd ../../frameworks/av && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/av/refs/changes/92/384692/2/*.patch`
cd ../../packages/inputmethods/LatinIME && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/packages/inputmethods/LatinIME/refs/changes/78/469478/1/*.patch`
cd ../../../

cd $ROOTDIR
