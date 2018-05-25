#!/bin/bash
# Script to extract AOSP build instructions
# Copyright (C) 2018 Adrien Bioteau - All Rights Reserved
# Permission to copy and modify is granted under the GPLv3 license
# Last revised 04/05/2018

mkdir -p orig
mkdir -p sonyxperiadev

#For each AOSP build instructions
buildInstructionsList="kitkat-4.4 lollipop-5.0 lollipop-5.1 marshmallow-6.0 marshmallow-6.0.1 nougat-7.0 nougat-7.1.1-legacy nougat-7.1.1 nougat-7.1.2 oreo-8.0 oreo-8.1"
for buildInstruction in ${buildInstructionsList};
do
    versionName=`echo ${buildInstruction} | \
                    sed 's/\([a-z]*\)-.*/\1/g'`
    versionNumber=`echo ${buildInstruction} | \
                    sed 's/[a-z]*-\([0-9.]*\).*/\1/g'`
    versionTag=`echo ${buildInstruction} | \
                    sed 's/[a-z]*-[0-9.]*\(.*\)/\1/g' |
                    sed 's/-//g'`

    if [[ -z ${versionTag} ]]
    then
        outdir=sonyxperiadev/${versionName}/${versionNumber}
    else
        outdir=sonyxperiadev/${versionName}/${versionNumber}-${versionTag}
    fi

    mkdir -p ${outdir}

    # Get AOSP patches
    echo "#!/bin/bash" > orig/${versionName}-${versionNumber}-${versionTag}-patch.sh
    echo "" >> orig/${versionName}-${versionNumber}-${versionTag}-patch.sh
    echo "BASEDIR=`pwd`" >> orig/${versionName}-${versionNumber}-${versionTag}-patch.sh
    echo "" >> orig/${versionName}-${versionNumber}-${versionTag}-patch.sh
    grep -o "git fetch[^&]*" ${outdir}/AOSP_PATCH | \
    sed 's/git fetch http[s]*\:\/\/android.googlesource.com\/\([a-zA-Z0-9\/\_\-]*\) \(.*\)/mkdir -p \$\{BASEDIR\}\/orig\/\1 \&\& git clone https\:\/\/android.googlesource.com\/\1 \$\{BASEDIR\}\/orig\/\1/' >> orig/${versionName}-${versionNumber}-${versionTag}-patch.sh
    grep -o "git fetch[^&]*" ${outdir}/AOSP_PATCH | \
    sed 's/git fetch http[s]*\:\/\/android.googlesource.com\/\([a-zA-Z0-9\/\_\-]*\) \(.*\)/cd \$\{BASEDIR\}\/orig\/\1 \&\& git fetch origin \2 \&\& mkdir -p \$\{BASEDIR\}\/sonyxperiadev\/patches\/\1\/\2 \&\& git format-patch FETCH_HEAD^! -o \$\{BASEDIR\}\/sonyxperiadev\/patches\/\1\/\2 \&\& cd -/' >> orig/${versionName}-${versionNumber}-${versionTag}-patch.sh
    chmod +x orig/${versionName}-${versionNumber}-${versionTag}-patch.sh
    ./orig/${versionName}-${versionNumber}-${versionTag}-patch.sh

    # Generate script to apply AOSP patches
    echo "#!/bin/bash" > ${outdir}/apply_patch.sh
    echo "# Script to apply Sony Xperia patches" >> ${outdir}/apply_patch.sh
    echo "# Copyright (C) 2018 Adrien Bioteau - All Rights Reserved" >> ${outdir}/apply_patch.sh
    echo "# Permission to copy and modify is granted under the GPLv3 license" >> ${outdir}/apply_patch.sh
    echo "# Last revised 04/09/2018" >> ${outdir}/apply_patch.sh
    echo "" >> ${outdir}/apply_patch.sh
    echo "relpath () {" >> ${outdir}/apply_patch.sh
    echo "    [ \$# -ge 1 ] && [ \$# -le 2 ] || return 1" >> ${outdir}/apply_patch.sh
    echo "    current=\"\${2:+\"\$1\"}\"" >> ${outdir}/apply_patch.sh
    echo "    target=\"\${2:-\"\$1\"}\"" >> ${outdir}/apply_patch.sh
    echo "    if [[ \"\$target\" = \"http\"* ]] || [[ \"\$current\" = \"http\"* ]]; then" >> ${outdir}/apply_patch.sh
    echo "        echo \"\$target\"" >> ${outdir}/apply_patch.sh
    echo "        return 0" >> ${outdir}/apply_patch.sh
    echo "    fi" >> ${outdir}/apply_patch.sh
    echo "    [ \"\$target\" != . ] || target=/" >> ${outdir}/apply_patch.sh
    echo "    target=\"/\${target##/}\"" >> ${outdir}/apply_patch.sh
    echo "    [ \"\$current\" != . ] || current=/" >> ${outdir}/apply_patch.sh
    echo "    current=\"\${current:=\"/\"}\"" >> ${outdir}/apply_patch.sh
    echo "    current=\"/\${current##/}\"" >> ${outdir}/apply_patch.sh
    echo "    appendix=\"\${target##/}\"" >> ${outdir}/apply_patch.sh
    echo "    relative=''" >> ${outdir}/apply_patch.sh
    echo "    while appendix=\"\${target#\"\$current\"/}\"" >> ${outdir}/apply_patch.sh
    echo "        [ \"\$current\" != '/' ] && [ \"\$appendix\" = \"\$target\" ]; do" >> ${outdir}/apply_patch.sh
    echo "        if [ \"\$current\" = \"\$appendix\" ]; then" >> ${outdir}/apply_patch.sh
    echo "            relative=\"\${relative:-.}\"" >> ${outdir}/apply_patch.sh
    echo "            echo \"\${relative#/}\"" >> ${outdir}/apply_patch.sh
    echo "            return 0" >> ${outdir}/apply_patch.sh
    echo "        fi" >> ${outdir}/apply_patch.sh
    echo "        current=\"\${current%/*}\"" >> ${outdir}/apply_patch.sh
    echo "        relative=\"\$relative\${relative:+/}..\"" >> ${outdir}/apply_patch.sh
    echo "    done" >> ${outdir}/apply_patch.sh
    echo "    relative=\"\$relative\${relative:+\${appendix:+/}}\${appendix#/}\"" >> ${outdir}/apply_patch.sh
    echo "    echo \"\$relative\"" >> ${outdir}/apply_patch.sh
    echo "}" >> ${outdir}/apply_patch.sh
    echo "" >> ${outdir}/apply_patch.sh
    echo "cd \`dirname \$0\`/../../.." >> ${outdir}/apply_patch.sh
    echo "ROOTDIR=\`pwd\`" >> ${outdir}/apply_patch.sh
    echo "NB_CORES=\`grep -c ^processor /proc/cpuinfo\`" >> ${outdir}/apply_patch.sh
    echo "" >> ${outdir}/apply_patch.sh
    echo "if [ \$# -ne 5 ]" >> ${outdir}/apply_patch.sh
    echo "then" >> ${outdir}/apply_patch.sh
    echo "    echo \"[USAGE] ./apply_patch.sh <aosp_workspace> <aosp_mirror> <repo_mirror> <github_mirror> <git_branch>\"" >> ${outdir}/apply_patch.sh
    echo "    exit 1" >> ${outdir}/apply_patch.sh
    echo "fi" >> ${outdir}/apply_patch.sh
    echo "" >> ${outdir}/apply_patch.sh
    echo "AOSP_WORKSPACE=\$1" >> ${outdir}/apply_patch.sh
    echo "AOSP_MIRROR_URL=\$2" >> ${outdir}/apply_patch.sh
    echo "REPO_MIRROR_URL=\$3" >> ${outdir}/apply_patch.sh
    echo "GITHUB_MIRROR_URL=\$4" >> ${outdir}/apply_patch.sh
    echo "GITHUB_MIRROR_REL_URL=\$(relpath \$AOSP_MIRROR_URL/platform \$GITHUB_MIRROR_URL)" >> ${outdir}/apply_patch.sh
    echo "GIT_BRANCH=\$5" >> ${outdir}/apply_patch.sh
    echo "" >> ${outdir}/apply_patch.sh
    echo "mkdir -p \$AOSP_WORKSPACE" >> ${outdir}/apply_patch.sh
    echo "cd \$AOSP_WORKSPACE" >> ${outdir}/apply_patch.sh
    echo "~/bin/repo init -u \$AOSP_MIRROR_URL/platform/manifest.git --repo-url \$REPO_MIRROR_URL/git-repo.git -b "`cat ${outdir}/AOSP_TAG` >> ${outdir}/apply_patch.sh
    echo "" >> ${outdir}/apply_patch.sh
    if [[ -s ${outdir}/LOCAL_MANIFESTS_BRANCH ]]
    then
        echo "sed -i -e \"/^  <!-- Sony AOSP addons -->/d; /^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n\1/\" .repo/manifests/default.xml" >> ${outdir}/apply_patch.sh
        echo "git clone \$GITHUB_MIRROR_URL/abioteau/local_manifests" >> ${outdir}/apply_patch.sh
        echo "cd local_manifests" >> ${outdir}/apply_patch.sh
        echo "git checkout -f "`cat ${outdir}/LOCAL_MANIFESTS_BRANCH` >> ${outdir}/apply_patch.sh
        echo "sed -i \"s/fetch=\\\".*:\\/\\/github.com\\/\\(.*\\)\\\"/fetch=\\\"\$(echo \$GITHUB_MIRROR_REL_URL | sed 's/\//\\\\\//g')\\/\\1\\\"/\" *.xml" >> ${outdir}/apply_patch.sh
        echo "find *.xml | xargs -I {} sed -i -e \"/^  <include name=\\\"{}\\\"\/>/d; /^<\/manifest/ s/\(.*\)/  <include name=\\\"{}\\\"\/>\n\1/\" ../.repo/manifests/default.xml" >> ${outdir}/apply_patch.sh
        echo "cp *.xml ../.repo/manifests/." >> ${outdir}/apply_patch.sh
        echo "cd .." >> ${outdir}/apply_patch.sh
        echo "rm -rf local_manifests" >> ${outdir}/apply_patch.sh
    else
        echo "cp \$ROOTDIR/${outdir}/sony.xml .repo/manifests/sony.xml" >> ${outdir}/apply_patch.sh
        echo "sed -i \"s/fetch=\\\".*:\\/\\/github.com\\/\\(.*\\)\\\"/fetch=\\\"\$(echo \$GITHUB_MIRROR_REL_URL | sed 's/\//\\\\\//g')\\/\\1\\\"/\" .repo/manifests/sony.xml" >> ${outdir}/apply_patch.sh
        echo "sed -i \"/^<project/ s/name=\\\"/name=\\\"sonyxperiadev\//\" .repo/manifests/sony.xml" >> ${outdir}/apply_patch.sh
        echo "sed -i \"/^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n  <include name=\\\"sony.xml\\\"\/>\n\1/\" .repo/manifests/default.xml" >> ${outdir}/apply_patch.sh
    fi
    echo "" >> ${outdir}/apply_patch.sh
    echo "~/bin/repo sync -j \$NB_CORES" >> ${outdir}/apply_patch.sh
    echo "~/bin/repo manifest -o manifest.xml -r" >> ${outdir}/apply_patch.sh
    echo "" >> ${outdir}/apply_patch.sh
    cat ${outdir}/AOSP_PATCH | sed 's/cd \(.*[a-zA-Z0-9]+*\).*/cd \1 \&\& repo start \$GIT_BRANCH ./g' > orig/${versionName}-${versionNumber}-${versionTag}-apply_patch_1.sh
    cat orig/${versionName}-${versionNumber}-${versionTag}-apply_patch_1.sh | sed 's/git cherry-pick \([a-f0-9].*\)/git cherry-pick -n \1 \&\& export GIT_COMMITTER_DATE=\"\$(git log -1 --format=\"%ad\" \1)\" \&\& git commit --no-edit --author \"\$(git log -1 --format=\"%an <%ae>\" \1)\" --date \"\$(git log -1 --format=\"%ad\" \1)\" \&\& unset GIT_COMMITTER_DATE/g' > orig/${versionName}-${versionNumber}-${versionTag}-apply_patch_2.sh
    cat orig/${versionName}-${versionNumber}-${versionTag}-apply_patch_2.sh | sed 's/git fetch http[s]*\:\/\/android.googlesource.com\/\([a-zA-Z0-9\/-\_].*\) \(.*\) \&\& git cherry-pick FETCH_HEAD/git am -3 --committer-date-is-author-date `ls \$ROOTDIR\/sonyxperiadev\/patches\/\1\/\2\/*.patch`/g' > orig/${versionName}-${versionNumber}-${versionTag}-apply_patch_3.sh
    cat orig/${versionName}-${versionNumber}-${versionTag}-apply_patch_3.sh | sed 's/git revert --no-edit \([a-f0-9].*\)/git revert --no-edit --no-commit \1 \&\& export GIT_COMMITTER_DATE=\"`date +\"2017-01-01 08:00:00 \+0200\"`\" \&\& git commit --no-edit --author \"\$(git log -1 --format=\"%an <%ae>\" \1)\" --date \"\$(git log -1 --format=\"%ad\" \1)\" \&\& unset GIT_COMMITTER_DATE/g' >> ${outdir}/apply_patch.sh
    echo "" >> ${outdir}/apply_patch.sh
    echo "cd \$ROOTDIR" >> ${outdir}/apply_patch.sh
    chmod +x ${outdir}/apply_patch.sh
    /usr/bin/dos2unix ${outdir}/apply_patch.sh
done

rm -rf orig
