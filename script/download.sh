#!/bin/bash
# Script to extract AOSP build instructions
# Copyright (C) 2017 Adrien Bioteau - All Rights Reserved
# Permission to copy and modify is granted under the GPLv3 license
# Last revised 05/17/2017

mkdir -p sonyxperiadev

download_web_page() {
    wget $1 -O $2
    /usr/bin/tidy -mi --vertical-space no --wrap 0 --force-output yes $2
}

extract_section_from_web_page() {
    if [ $# -eq 5 ]
    then
        cat "$1" | \
        sed -n "$3" | \
        sed "$4" | \
        sed "$5" > "$2"
    else
        cat "$1" | \
        sed -n "$3" | \
        sed "$4" > "$2"
    fi
    /usr/bin/tidy -mi --vertical-space no --wrap 0 --force-output yes "$2"
}

check_null_web_page() {
    if [[ ! -s "$1" ]]
    then
        git checkout -- "$1"
        echo "`date` - Fail to get $1"
        exit 1
    fi
}

# Get latest update
mkdir -p orig
download_web_page "http://developer.sonymobile.com/open-devices/latest-updates/" orig/latest.html
extract_section_from_web_page orig/latest.html sonyxperiadev/latest-updates.html '/<div id="main" role="main"/,$p' '/<div class="column small-column sidebar-column">/q' 's/<div class="column small-column sidebar-column">//g'
check_null_web_page sonyxperiadev/latest-updates.html

# Get current platform functionality
download_web_page "http://developer.sonymobile.com/open-devices/current-platform-functionality/" orig/current.html
extract_section_from_web_page orig/current.html sonyxperiadev/current-platform-functionality.html '/<div id="main" role="main"/,$p' '/<div class="column small-column sidebar-column">/q' 's/<div class="column small-column sidebar-column">//g'
check_null_web_page sonyxperiadev/current-platform-functionality.html

# Get list of devices and ressources
download_web_page "http://developer.sonymobile.com/open-devices/list-of-devices-and-resources/" orig/list.html
extract_section_from_web_page orig/list.html sonyxperiadev/list-of-devices-and-resources.html '/<div id="main" role="main"/,$p' '/<div class="column small-column sidebar-column">/q' 's/<div class="column small-column sidebar-column">//g'
check_null_web_page sonyxperiadev/list-of-devices-and-resources.html

# Get list of Sony software binaries
mkdir -p orig/binary
download_web_page "http://developer.sonymobile.com/downloads/software-binaries/" orig/binary/index.html
extract_section_from_web_page orig/binary/index.html sonyxperiadev/software-binaries.html '/<div id="main" role="main"/,$p' '/<div class="column small-column sidebar-column">/q' 's/<div class="column small-column sidebar-column">//g'
check_null_web_page sonyxperiadev/software-binaries.html

# For each Sony software binaries
mkdir -p sonyxperiadev/binary
extract_section_from_web_page orig/binary/index.html orig/binary/body.html '/<tbody/,$p' '/\/tbody>/q'
binariesNumber=`cat orig/binary/body.html | grep -c "<tr>"`
counter=0
while [[ ${counter} -lt ${binariesNumber} ]];
do
    extract_section_from_web_page orig/binary/body.html orig/binary/body-${counter}.html '/<tr/,$p' '/\/tr>/q'

    eulaUrl=`grep -o 'https://dl.developer.sonymobile.com/eula[^"]*' orig/binary/body-${counter}.html`
    sourceUrl=`echo ${eulaUrl} | grep -o 'https://[^?]*'`
    nonce=`echo ${eulaUrl} | grep -o 'nonce=[^"]*' | \
        sed 's/nonce=//g'`
    callback=`echo ${eulaUrl} | grep -o 'callback=[^&]*' | \
        sed 's/callback=//g' | \
        sed 's/%3A/:/g' | \
        sed 's/%2F/\//g'`

    wget ${eulaUrl} -O orig/binary/eula-${counter}.html
    downloadUrl=`grep -o "https://dl.developer.sonymobile.com/eula[^\']*" orig/binary/eula-${counter}.html`
    binaryFile=`echo ${downloadUrl} | grep -o "restricted/[^\']*" | \
        sed 's/restricted\///g'`
    skipBinaryFile=`grep -c -o "${binaryFile}" sonyxperiadev/skip-binary.txt`
    if [[ ${skipBinaryFile} == 0 ]]
    then
        wget -c "${callback}?nonce=${nonce}&source=${sourceUrl}&url=${downloadUrl}" -O sonyxperiadev/binary/"${binaryFile}"
        commitMessage=`echo "released \`date +%Y-%m-%d\` => ${binaryFile}" | \
            sed 's/SW_binaries_for_//g' | \
            sed 's/.zip//g'`
        branchName=`echo "${binaryFile}" | \
            sed 's/SW_binaries_for_Xperia_AOSP_//g' | \
            sed 's/_v.*//g' | \
            tr '[:upper:]' '[:lower:]'`
        ./script/extract_binary.sh . "${binaryFile}" "${commitMessage}" "${branchName}" "${branchName}"
        if [ $? -ne 0 ]
        then
            exit 1
        fi
        echo "${binaryFile}" >> sonyxperiadev/skip-binary.txt
    fi

    extract_section_from_web_page orig/binary/body.html orig/binary/body.html.tmp '/\/tr>/,$p' '1s/<\/tr>//g'
    cp orig/binary/body.html.tmp orig/binary/body.html
    counter=$((counter+1))
done

# Get list of AOSP build instructions
download_web_page "http://developer.sonymobile.com/open-devices/aosp-build-instructions/" orig/index.html
extract_section_from_web_page orig/index.html sonyxperiadev/aosp-build-instructions.html '/<div id="main" role="main"/,$p' '/<div class="column small-column sidebar-column">/q' 's/<div class="column small-column sidebar-column">//g'
check_null_web_page sonyxperiadev/aosp-build-instructions.html
if [[ -s sonyxperiadev/aosp-build-instructions.html ]]
then
    aospVersionNumber=`cat sonyxperiadev/aosp-build-instructions.html | \
        grep -c "http://developer.sonymobile.com/open-devices/aosp-build-instructions/"`
    aospVersionCounter=0
fi

# Get AOSP Kitkat build instructions
mkdir -p orig/kitkat
download_web_page "http://developer.sonymobile.com/open-devices/aosp-build-instructions/how-to-build-aosp-kitkat-for-unlocked-xperia-devices/" orig/kitkat/index.html
extract_section_from_web_page orig/kitkat/index.html sonyxperiadev/build-aosp-kitkat-4.4.html '/<div id="main" role="main"/,$p' '/<div class="column small-column sidebar-column">/q' 's/<div class="column small-column sidebar-column">//g'
check_null_web_page sonyxperiadev/build-aosp-kitkat-4.4.html
aospVersionCounter=$((aospVersionCounter+1))

# Get AOSP Lollipop build instructions
mkdir -p orig/lollipop
download_web_page "http://developer.sonymobile.com/open-devices/aosp-build-instructions/how-to-build-aosp-lollipop-for-unlocked-xperia-devices/" orig/lollipop/index.html.tmp
extract_section_from_web_page orig/lollipop/index.html.tmp orig/lollipop/index.html '/<div id="main" role="main"/,$p' '/<div class="column small-column sidebar-column">/q' 's/<div class="column small-column sidebar-column">//g'
extract_section_from_web_page orig/lollipop/index.html sonyxperiadev/build-aosp-lollipop-5.0.html '/<dt id="build-aosp-lollipop-5-0"/,$p' '/\/dd>/q'
check_null_web_page sonyxperiadev/build-aosp-lollipop-5.0.html
extract_section_from_web_page orig/lollipop/index.html sonyxperiadev/build-aosp-lollipop-5.1.html '/<dt id="build-aosp-lollipop-5-1"/,$p' '/\/dd>/q'
check_null_web_page sonyxperiadev/build-aosp-lollipop-5.1.html
aospVersionCounter=$((aospVersionCounter+1))

# Get AOSP Marshmallow build instructions
mkdir -p orig/marshmallow
download_web_page "http://developer.sonymobile.com/open-devices/aosp-build-instructions/how-to-build-aosp-marshmallow-for-unlocked-xperia-devices/" orig/marshmallow/index.html.tmp
extract_section_from_web_page orig/marshmallow/index.html.tmp orig/marshmallow/index.html '/<div id="main" role="main"/,$p' '/<div class="column small-column sidebar-column">/q' 's/<div class="column small-column sidebar-column">//g'
extract_section_from_web_page orig/marshmallow/index.html sonyxperiadev/build-aosp-marshmallow-6.0.html '/<dt id="build-aosp-marshmallow-6.0"/,$p' '/\/dd>/q'
check_null_web_page sonyxperiadev/build-aosp-marshmallow-6.0.html
extract_section_from_web_page orig/marshmallow/index.html sonyxperiadev/build-aosp-marshmallow-6.0.1.html '/<dt id="build-aosp-marshmallow-experimental"/,$p' '/\/dd>/q'
check_null_web_page sonyxperiadev/build-aosp-marshmallow-6.0.1.html
aospVersionCounter=$((aospVersionCounter+1))

# Get AOSP Nougat build instructions
mkdir -p orig/nougat
download_web_page "http://developer.sonymobile.com/open-devices/aosp-build-instructions/how-to-build-aosp-nougat-for-unlocked-xperia-devices/" orig/nougat/index.html.tmp
extract_section_from_web_page orig/nougat/index.html.tmp orig/nougat/index.html '/<div id="main" role="main"/,$p' '/<div class="column small-column sidebar-column">/q' 's/<div class="column small-column sidebar-column">//g'
aospNougatNumber=`cat orig/nougat/index.html | \
    grep -c "<dt id=\"build"`
aospNougatCounter=0
extract_section_from_web_page orig/nougat/index.html sonyxperiadev/build-aosp-nougat-7.0.html '/<dt id="build-aosp-nougat-7-0"/,$p' '/\/dd>/q'
check_null_web_page sonyxperiadev/build-aosp-nougat-7.0.html
if [[ -s sonyxperiadev/build-aosp-nougat-7.0.html ]]
then
    aospNougatCounter=$((aospNougatCounter+1))
fi
extract_section_from_web_page orig/nougat/index.html sonyxperiadev/build-aosp-nougat-7.1-kernel-3.10.html '/<dt id="build-aosp-nougat-7-1"/,$p' '/\/dd>/q'
check_null_web_page sonyxperiadev/build-aosp-nougat-7.1-kernel-3.10.html
if [[ -s sonyxperiadev/build-aosp-nougat-7.1-kernel-3.10.html ]]
then
    aospNougatCounter=$((aospNougatCounter+1))
fi
extract_section_from_web_page orig/nougat/index.html sonyxperiadev/build-aosp-nougat-7.1-kernel-3.18.html '/<dt id="build-experimental-aosp-nougat-7-1"/,$p' '/\/dd>/q'
check_null_web_page sonyxperiadev/build-aosp-nougat-7.1-kernel-3.18.html
if [[ -s sonyxperiadev/build-aosp-nougat-7.1-kernel-3.18.html ]]
then
    aospNougatCounter=$((aospNougatCounter+1))
fi
extract_section_from_web_page orig/nougat/index.html sonyxperiadev/build-aosp-nougat-7.1-kernel-4.4.html '/<dt id="build-aosp-nougat-7-1-kernel-4-4-experimental"/,$p' '/\/dd>/q'
check_null_web_page sonyxperiadev/build-aosp-nougat-7.1-kernel-4.4.html
if [[ -s sonyxperiadev/build-aosp-nougat-7.1-kernel-4.4.html ]]
then
    aospNougatCounter=$((aospNougatCounter+1))
fi
aospVersionCounter=$((aospVersionCounter+1))

# Check if there a new AOSP version
if [[ ${aospVersionCounter} < ${aospVersionNumber} || ${aospNougatCounter} < ${aospNougatNumber} ]]
then
    echo "`date` - Download script need to be update in order to get new AOSP version"
    exit 1
fi

#For each AOSP build instructions
buildInstructionsFile=`find sonyxperiadev/build-aosp-*.html`
for file in ${buildInstructionsFile};
do
    versionName=`echo ${file} | \
                    sed 's/sonyxperiadev\/build-aosp-\([a-z]*\)-.*/\1/g'`
    versionNumber=`echo ${file} | \
                    sed 's/sonyxperiadev\/build-aosp-[a-z]*-\([0-9.]*\).*\.html/\1/g'`
    versionTag=`echo ${file} | \
                    sed 's/sonyxperiadev\/build-aosp-[a-z]*-[0-9.]*\(.*\)\.html/\1/g'`
    outdir=sonyxperiadev/${versionName}/${versionNumber}${versionTag}

    mkdir -p ${outdir}

    if [[ -n $(git status -s ${file}) ]]
    then
        # Extract AOSP reference tag
        grep "repo init" ${file} | \
            grep -o -E "android-[0-9._r]*" > ${outdir}/AOSP_TAG
        /usr/bin/dos2unix ${outdir}/AOSP_TAG

        # Extract Sony repository manifest
        grep -o "git checkout [a-zA-Z0-9.\/\_\-]*" ${file} | \
            sed 's/git checkout //g' > ${outdir}/LOCAL_MANIFESTS_BRANCH
        /usr/bin/dos2unix ${outdir}/LOCAL_MANIFESTS_BRANCH

        if [[ -s ${outdir}/LOCAL_MANIFESTS_BRANCH ]]
        then
            rm -f ${outdir}/sony.xml
            git rm -f ${outdir}/sony.xml
        else
            cat ${file} | \
                sed 's/<br>//g' | \
                sed 's/&lt;/\</g' | \
                sed 's/&quot;/\"/g' | \
                sed 's/&gt;/\>/g' | \
                sed 's/.*<?xml version/<?xml version/g' | \
                sed 's/\/manifest>.*/\/manifest>/g' | \
                sed -n '/<?xml version/,$p' | \
                sed '/\/manifest>/q' | \
                sed 's/    //g' > ${outdir}/sony.xml
            /usr/bin/dos2unix ${outdir}/sony.xml

            rm -f ${outdir}/LOCAL_MANIFESTS_BRANCH
            git rm -f ${outdir}/LOCAL_MANIFESTS_BRANCH
        fi

        # Extract list of AOSP patches
        cat ${file} | \
            sed 's/<br>//g' | \
            sed 's/.*cd /cd /g' | \
            sed 's/\/li>.*/\/li>/g' | \
            sed -n '/cd [bhesp][uaxya][irtsc]/,$p' | \
            sed '/\/li\>/q' | \
            sed 's/    //g' | \
            sed 's/<\/pre>//g' | \
            sed 's/<\/li>//g' | \
            sed 's/<\/code>//g' > ${outdir}/AOSP_PATCH
        /usr/bin/dos2unix ${outdir}/AOSP_PATCH

        if [[ -n $(git status -s ${outdir}/AOSP_PATCH) ]]
        then
            # Get AOSP patches
            echo "#!/bin/bash" > orig/${versionName}-${versionNumber}${versionTag}-patch.sh
            echo "" >> orig/${versionName}-${versionNumber}${versionTag}-patch.sh
            echo "BASEDIR=`pwd`" >> orig/${versionName}-${versionNumber}${versionTag}-patch.sh
            echo "" >> orig/${versionName}-${versionNumber}${versionTag}-patch.sh
            grep -o "git fetch[^&]*" ${outdir}/AOSP_PATCH | \
            sed 's/git fetch http[s]*\:\/\/android.googlesource.com\/\([a-zA-Z0-9\/\_\-]*\) \(.*\)/mkdir -p \$\{BASEDIR\}\/orig\/\1 \&\& git clone https\:\/\/android.googlesource.com\/\1 \$\{BASEDIR\}\/orig\/\1/' >> orig/${versionName}-${versionNumber}${versionTag}-patch.sh
            grep -o "git fetch[^&]*" ${outdir}/AOSP_PATCH | \
            sed 's/git fetch http[s]*\:\/\/android.googlesource.com\/\([a-zA-Z0-9\/\_\-]*\) \(.*\)/cd \$\{BASEDIR\}\/orig\/\1 \&\& git fetch origin \2 \&\& mkdir -p \$\{BASEDIR\}\/sonyxperiadev\/patches\/\1\/\2 \&\& git format-patch FETCH_HEAD^! -o \$\{BASEDIR\}\/sonyxperiadev\/patches\/\1\/\2 \&\& cd -/' >> orig/${versionName}-${versionNumber}${versionTag}-patch.sh
            chmod +x orig/${versionName}-${versionNumber}${versionTag}-patch.sh
            ./orig/${versionName}-${versionNumber}${versionTag}-patch.sh
        fi
    fi

    # Generate script to apply AOSP patches
    echo "#!/bin/bash" > ${outdir}/apply_patch.sh
    echo "# Script to apply Sony Xperia patches" >> ${outdir}/apply_patch.sh
    echo "# Copyright (C) 2017 Adrien Bioteau - All Rights Reserved" >> ${outdir}/apply_patch.sh
    echo "# Permission to copy and modify is granted under the GPLv3 license" >> ${outdir}/apply_patch.sh
    echo "# Last revised 05/17/2017" >> ${outdir}/apply_patch.sh
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
    echo "GIT_BRANCH=\$5" >> ${outdir}/apply_patch.sh
    echo "" >> ${outdir}/apply_patch.sh
    echo "mkdir -p \$AOSP_WORKSPACE" >> ${outdir}/apply_patch.sh
    echo "cd \$AOSP_WORKSPACE" >> ${outdir}/apply_patch.sh
    echo "~/bin/repo init -u \$AOSP_MIRROR_URL/platform/manifest.git --repo-url \$REPO_MIRROR_URL/git-repo.git -b "`cat ${outdir}/AOSP_TAG` >> ${outdir}/apply_patch.sh
    echo "" >> ${outdir}/apply_patch.sh
    if [[ -s ${outdir}/LOCAL_MANIFESTS_BRANCH ]]
    then
        echo "sed -i \"/^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n\1/\" .repo/manifests/default.xml" >> ${outdir}/apply_patch.sh
        for repo in "sonyxperiadev/local_manifests" "abioteau/vendor_manifests"
        do
            repodir=`basename -s .git $repo`
            echo "git clone \$GITHUB_MIRROR_URL/$repo" >> ${outdir}/apply_patch.sh
            echo "cd $repodir" >> ${outdir}/apply_patch.sh
            echo "git checkout -f "`cat ${outdir}/LOCAL_MANIFESTS_BRANCH` >> ${outdir}/apply_patch.sh
            echo "sed -i \"s/fetch=\\\".*:\\/\\/github.com\\/\\(.*\\)\\\"/fetch=\\\"\$(echo \$GITHUB_MIRROR_URL | sed 's/\//\\\\\//g')\\/\\1\\\"/\" *.xml" >> ${outdir}/apply_patch.sh
            echo "find *.xml | xargs -I {} sed -i \"/^<\/manifest/ s/\(.*\)/  <include name=\\\"{}\\\"\/>\n\1/\" ../.repo/manifests/default.xml" >> ${outdir}/apply_patch.sh
            echo "cp *.xml ../.repo/manifests/." >> ${outdir}/apply_patch.sh
            echo "cd .." >> ${outdir}/apply_patch.sh
            echo "rm -rf $repodir" >> ${outdir}/apply_patch.sh
        done
    else
        echo "cp \$ROOTDIR/${outdir}/sony.xml .repo/manifests/sony.xml" >> ${outdir}/apply_patch.sh
        echo "sed -i \"s/fetch=\\\".*:\\/\\/github.com\\/\\(.*\\)\\\"/fetch=\\\"\$(echo \$GITHUB_MIRROR_URL | sed 's/\//\\\\\//g')\\/\\1\\\"/\" .repo/manifests/sony.xml" >> ${outdir}/apply_patch.sh
        echo "sed -i \"/^<project/ s/name=\\\"/name=\\\"sonyxperiadev\//\" .repo/manifests/sony.xml" >> ${outdir}/apply_patch.sh
        echo "sed -i \"/^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n  <include name=\\\"sony.xml\\\"\/>\n\1/\" .repo/manifests/default.xml" >> ${outdir}/apply_patch.sh
    fi
    echo "" >> ${outdir}/apply_patch.sh
    echo "~/bin/repo sync -j \$NB_CORES" >> ${outdir}/apply_patch.sh
    echo "~/bin/repo manifest -o manifest.xml -r" >> ${outdir}/apply_patch.sh
    echo "" >> ${outdir}/apply_patch.sh
    cat ${outdir}/AOSP_PATCH | sed 's/cd \(.*[a-zA-Z0-9]+*\).*/cd \1 \&\& repo start \$GIT_BRANCH ./g' > orig/${versionName}-${versionNumber}${versionTag}-apply_patch_1.sh
    cat orig/${versionName}-${versionNumber}${versionTag}-apply_patch_1.sh | sed 's/git cherry-pick \([a-f0-9].*\)/git format-patch -o \/tmp\/\1 -1 \1 \&\& git am -3 --committer-date-is-author-date \/tmp\/\1\/0001-*.patch \&\& rm -rf \/tmp\/\1/g' > orig/${versionName}-${versionNumber}${versionTag}-apply_patch_2.sh
    cat orig/${versionName}-${versionNumber}${versionTag}-apply_patch_2.sh | sed 's/git fetch http[s]*\:\/\/android.googlesource.com\/\([a-zA-Z0-9\/-\_].*\) \(.*\) &amp;&amp; git cherry-pick FETCH_HEAD/git am -3 --committer-date-is-author-date `ls \$ROOTDIR\/sonyxperiadev\/patches\/\1\/\2\/*.patch`/g' > orig/${versionName}-${versionNumber}${versionTag}-apply_patch_3.sh
    cat orig/${versionName}-${versionNumber}${versionTag}-apply_patch_3.sh | sed 's/git revert --no-edit \([a-f0-9].*\)/git revert --no-edit --no-commit \1 \&\& export GIT_COMMITTER_DATE=\"`date +\"2017-01-01 08:00:00 \+0200\"`\" \&\& git commit -m \"`cat .git\/MERGE_MSG`\" --author \"`git log -1 \1 | grep \"Author: \" | sed -e \"s\/Author: \/\/\"`\" --date \"`git log -1 \1 | grep \"Date:   \" | sed -e \"s\/Date:   \/\/\"`\" \&\& unset GIT_COMMITTER_DATE/g' >> ${outdir}/apply_patch.sh
    echo "" >> ${outdir}/apply_patch.sh
    echo "cd \$ROOTDIR" >> ${outdir}/apply_patch.sh
    chmod +x ${outdir}/apply_patch.sh
    /usr/bin/dos2unix ${outdir}/apply_patch.sh
done

rm -rf orig
