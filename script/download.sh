#!/bin/bash
# Script to extract AOSP build instructions
# Copyright (C) 2016 Adrien Bioteau - All Rights Reserved
# Permission to copy and modify is granted under the GPLv3 license
# Last revised 12/21/2016

mkdir -p sonyxperiadev

download_web_page() {
    wget $1 -O $2
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
}

check_null_web_page() {
    if [[ ! -s "$1" ]]
    then
        git checkout -- "$1"
        echo "`date` - Fail to get $1"
    fi
}

# Get latest update
mkdir -p orig
download_web_page "http://developer.sonymobile.com/open-devices/latest-updates/" orig/latest.html
extract_section_from_web_page orig/latest.html sonyxperiadev/latest-updates.html '/<article class="article page-article"/,$p' '/article>/q'
check_null_web_page sonyxperiadev/latest-updates.html

# Get current platform functionality
download_web_page "http://developer.sonymobile.com/open-devices/current-platform-functionality/" orig/current.html
extract_section_from_web_page orig/current.html sonyxperiadev/current-platform-functionality.html '/<article class="article page-article"/,$p' '/article>/q' 's/<!-- \#tablepress\(.*\)-->//g'
check_null_web_page sonyxperiadev/current-platform-functionality.html

# Get list of devices and ressources
download_web_page "http://developer.sonymobile.com/open-devices/list-of-devices-and-resources/" orig/list.html
extract_section_from_web_page orig/list.html sonyxperiadev/list-of-devices-and-resources.html '/<article class="article page-article"/,$p' '/article>/q'
check_null_web_page sonyxperiadev/list-of-devices-and-resources.html

# Get list of Sony software binaries
mkdir -p orig/binary
download_web_page "http://developer.sonymobile.com/downloads/software-binaries/" orig/binary/index.html
extract_section_from_web_page orig/binary/index.html sonyxperiadev/software-binaries.html '/<div class="section downloads-section"/,$p' '/div>/q'
check_null_web_page sonyxperiadev/software-binaries.html

# For each Sony software binaries
mkdir -p sonyxperiadev/binary
extract_section_from_web_page orig/binary/index.html orig/binary/body.html '/<tbody/,$p' '/\/tbody>/q'
binariesNumber=`cat orig/binary/body.html | grep -c "<tr>"`
counter=0
while [[ ${counter} < ${binariesNumber} ]];
do
    extract_section_from_web_page orig/binary/body.html orig/binary/body-${counter}.html '/<tr/,$p' '/\/tr>/q'

    grep -o 'http://dl-developer.sonymobile.com/eula[^"]*' orig/binary/body-${counter}.html | \
        xargs -I {} wget {} -O orig/binary/eula-${counter}.html
    binaryFile=`grep -o "restricted/[^\']*" orig/binary/eula-${counter}.html | \
        sed 's/\?param=//g' | \
        sed 's/restricted\///g'`
    skipBinaryFile=`grep -c -o "${binaryFile}" sonyxperiadev/skip-binary.txt`
    if [[ ${skipBinaryFile} == 0 ]]
    then
        wget -c --no-cookies --header "Cookie: dw_accepted=true" "http://dl-developer.sonymobile.com/eula/restricted/${binaryFile}" -O sonyxperiadev/binary/"${binaryFile}"
        commitMessage=`echo "released \`date +%Y-%m-%d\` => ${binaryFile}" | \
            sed 's/SW_binaries_for_//g' | \
            sed 's/.zip//g'`
        branchName=`echo "${binaryFile}" | \
            sed 's/SW_binaries_for_Xperia_AOSP_//g' | \
            sed 's/_v.*//g' | \
            tr '[:upper:]' '[:lower:]' | \
            tr '_' '-'`
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
extract_section_from_web_page orig/index.html sonyxperiadev/aosp-build-instructions.html '/<div class="section overview-section main-overview-section"/,$p' '/<div class="column small-column sidebar-column">/q' 's/<div class="column small-column sidebar-column">//g'
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
extract_section_from_web_page orig/kitkat/index.html sonyxperiadev/build-aosp-kitkat-4.4.html '/<article class="article page-article"/,$p' '/article>/q'
check_null_web_page sonyxperiadev/build-aosp-kitkat-4.4.html
aospVersionCounter=$((aospVersionCounter+1))

# Get AOSP Lollipop build instructions
mkdir -p orig/lollipop
download_web_page "http://developer.sonymobile.com/open-devices/aosp-build-instructions/how-to-build-aosp-lollipop-for-unlocked-xperia-devices/" orig/lollipop/index.html.tmp
extract_section_from_web_page orig/lollipop/index.html.tmp orig/lollipop/index.html '/<div class="section overview-section faq-overview-section"/,$p' '/div>/q'
extract_section_from_web_page orig/lollipop/index.html sonyxperiadev/build-aosp-lollipop-5.0.html '/<dt id="build-aosp-lollipop-5-0"/,$p' '/\/dd>/q'
check_null_web_page sonyxperiadev/build-aosp-lollipop-5.0.html
extract_section_from_web_page orig/lollipop/index.html sonyxperiadev/build-aosp-lollipop-5.1.html '/<dt id="build-aosp-lollipop-5-1"/,$p' '/\/dd>/q'
check_null_web_page sonyxperiadev/build-aosp-lollipop-5.1.html
aospVersionCounter=$((aospVersionCounter+1))

# Get AOSP Marshmallow build instructions
mkdir -p orig/marshmallow
download_web_page "http://developer.sonymobile.com/open-devices/aosp-build-instructions/how-to-build-aosp-marshmallow-for-unlocked-xperia-devices/" orig/marshmallow/index.html.tmp
extract_section_from_web_page orig/marshmallow/index.html.tmp orig/marshmallow/index.html '/<div class="section overview-section faq-overview-section"/,$p' '/div>/q'
extract_section_from_web_page orig/marshmallow/index.html sonyxperiadev/build-aosp-marshmallow-6.0.html '/<dt id="build-aosp-marshmallow-6.0"/,$p' '/\/dd>/q'
check_null_web_page sonyxperiadev/build-aosp-marshmallow-6.0.html
extract_section_from_web_page orig/marshmallow/index.html sonyxperiadev/build-aosp-marshmallow-6.0.1.html '/<dt id="build-aosp-marshmallow-experimental"/,$p' '/\/dd>/q'
check_null_web_page sonyxperiadev/build-aosp-marshmallow-6.0.1.html
aospVersionCounter=$((aospVersionCounter+1))

# Get AOSP Nougat build instructions
mkdir -p orig/nougat
download_web_page "http://developer.sonymobile.com/open-devices/aosp-build-instructions/how-to-build-aosp-nougat-for-unlocked-xperia-devices/" orig/nougat/index.html.tmp
extract_section_from_web_page orig/nougat/index.html.tmp orig/nougat/index.html '/<div class="section overview-section faq-overview-section"/,$p' '/div>/q'
aospNougatNumber=`cat orig/nougat/index.html | \
    grep -c "<dt id=\"build"`
aospNougatCounter=0
extract_section_from_web_page orig/nougat/index.html sonyxperiadev/build-aosp-nougat-7.0.html '/<dt id="build-aosp-nougat-7-0"/,$p' '/\/dd>/q'
check_null_web_page sonyxperiadev/build-aosp-nougat-7.0.html
if [[ -s sonyxperiadev/build-aosp-nougat-7.0.html ]]
then
    aospNougatCounter=$((aospNougatCounter+1))
fi
extract_section_from_web_page orig/nougat/index.html sonyxperiadev/build-aosp-nougat-7.1.html '/<dt id="build-experimental-aosp-nougat-7-1"/,$p' '/\/dd>/q'
check_null_web_page sonyxperiadev/build-aosp-nougat-7.1.html
if [[ -s sonyxperiadev/build-aosp-nougat-7.1.html ]]
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
                    sed 's/sonyxperiadev\/build-aosp-//g' | \
                    sed 's/[0-9.]//g' | \
                    sed 's/.html//g'`
    versionNumber=`echo ${file} | \
                    sed 's/sonyxperiadev\/build-aosp-[a-z]*-//g' | \
                    sed 's/.html//g'`
    outdir=sonyxperiadev/${versionName}/${versionNumber}

    mkdir -p ${outdir}

    if [[ -n $(git status -s ${file}) ]]
    then
        # Extract AOSP reference tag
        grep "repo init" ${file} | \
            grep -o -E "android-[0-9._r]*" > ${outdir}/AOSP_TAG
        /usr/bin/dos2unix ${outdir}/AOSP_TAG

        # Extract Sony repository manifest
        cat ${file} | \
            sed 's/<br \/>//g' | \
            sed 's/&lt;/\</g' | \
            sed 's/&quot;/\"/g' | \
            sed 's/&gt;/\>/g' | \
            sed 's/.*<?xml version/<?xml version/g' | \
            sed 's/\/manifest>.*/\/manifest>/g' | \
            sed -n '/<?xml version/,$p' | \
            sed '/\/manifest>/q' > ${outdir}/sony.xml
        /usr/bin/dos2unix ${outdir}/sony.xml

        # Extract list of AOSP patches
        cat ${file} | \
            sed 's/<br \/>//g' | \
            sed 's/.*cd /cd /g' | \
            sed 's/\/li>.*/\/li>/g' | \
            sed -n '/cd [build|hardware|external|system|packages]/,$p' | \
            sed '/\/li\>/q' | \
            sed 's/<\/pre>//g' | \
            sed 's/<\/li>//g' | \
            sed 's/<\/code>//g' > ${outdir}/AOSP_PATCH
        /usr/bin/dos2unix ${outdir}/AOSP_PATCH

        if [[ -n $(git status -s ${outdir}/AOSP_PATCH) ]]
        then
            # Get AOSP patches
            echo "#!/bin/bash" > orig/${versionName}-${versionNumber}-patch.sh
            echo "" >> orig/${versionName}-${versionNumber}-patch.sh
            echo "BASEDIR=`pwd`" >> orig/${versionName}-${versionNumber}-patch.sh
            echo "" >> orig/${versionName}-${versionNumber}-patch.sh
            grep -o "git fetch[^&]*" ${outdir}/AOSP_PATCH | \
            sed 's/git fetch https\:\/\/android.googlesource.com\/\([a-zA-Z0-9\/\_\-]*\) \(.*\)/mkdir -p \$\{BASEDIR\}\/orig\/\1 \&\& git clone https\:\/\/android.googlesource.com\/\1 \$\{BASEDIR\}\/orig\/\1/' >> orig/${versionName}-${versionNumber}-patch.sh
            grep -o "git fetch[^&]*" ${outdir}/AOSP_PATCH | \
            sed 's/git fetch https\:\/\/android.googlesource.com\/\([a-zA-Z0-9\/\_\-]*\) \(.*\)/cd \$\{BASEDIR\}\/orig\/\1 \&\& git fetch origin \2 \&\& mkdir -p \$\{BASEDIR\}\/sonyxperiadev\/patches\/\1\/\2 \&\& git format-patch FETCH_HEAD^! -o \$\{BASEDIR\}\/sonyxperiadev\/patches\/\1\/\2 \&\& cd -/' >> orig/${versionName}-${versionNumber}-patch.sh
            chmod +x orig/${versionName}-${versionNumber}-patch.sh
            ./orig/${versionName}-${versionNumber}-patch.sh
        fi
    fi

    # Generate script to apply AOSP patches
    echo "#!/bin/bash" > ${outdir}/apply_patch.sh
    echo "# Script to apply Sony Xperia patches" >> ${outdir}/apply_patch.sh
    echo "# Copyright (C) 2016 Adrien Bioteau - All Rights Reserved" >> ${outdir}/apply_patch.sh
    echo "# Permission to copy and modify is granted under the GPLv3 license" >> ${outdir}/apply_patch.sh
    echo "# Last revised 12/13/2016" >> ${outdir}/apply_patch.sh
    echo "" >> ${outdir}/apply_patch.sh
    echo "cd \`dirname \$0\`/../../.." >> ${outdir}/apply_patch.sh
    echo "ROOTDIR=\`pwd\`" >> ${outdir}/apply_patch.sh
    echo "" >> ${outdir}/apply_patch.sh
    echo "if [ \$# -ne 5 ]" >> ${outdir}/apply_patch.sh
    echo "then" >> ${outdir}/apply_patch.sh
    echo "    echo \"[USAGE] ./apply_patch.sh <aosp_workspace> <aosp_mirror> <repo_mirror> <sony_mirror> <git_branch>\"" >> ${outdir}/apply_patch.sh
    echo "    exit 1" >> ${outdir}/apply_patch.sh
    echo "fi" >> ${outdir}/apply_patch.sh
    echo "" >> ${outdir}/apply_patch.sh
    echo "AOSP_WORKSPACE=\$1" >> ${outdir}/apply_patch.sh
    echo "AOSP_MIRROR_URL=\$2" >> ${outdir}/apply_patch.sh
    echo "REPO_MIRROR_URL=\$3" >> ${outdir}/apply_patch.sh
    echo "SONY_MIRROR_URL=\$(echo \$4 | sed 's/\//\\\\\//g')" >> ${outdir}/apply_patch.sh
    echo "GIT_BRANCH=\$5" >> ${outdir}/apply_patch.sh
    echo "" >> ${outdir}/apply_patch.sh
    echo "mkdir -p \$AOSP_WORKSPACE" >> ${outdir}/apply_patch.sh
    echo "cd \$AOSP_WORKSPACE" >> ${outdir}/apply_patch.sh
    echo "~/bin/repo init -u \$AOSP_MIRROR_URL/platform/manifest.git --repo-url \$REPO_MIRROR_URL/git-repo.git -b "`cat ${outdir}/AOSP_TAG` >> ${outdir}/apply_patch.sh
    echo "cp \$ROOTDIR/${outdir}/sony.xml .repo/manifests/sony.xml" >> ${outdir}/apply_patch.sh
    echo "sed -i \"s/fetch=\\\".*\\\"/fetch=\\\"\$SONY_MIRROR_URL\\\"/\" .repo/manifests/sony.xml" >> ${outdir}/apply_patch.sh
    echo "sed -i \"/^<project/ s/name=\\\"/name=\\\"sonyxperiadev\//\" .repo/manifests/sony.xml" >> ${outdir}/apply_patch.sh
    echo "sed -i \"/^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n  <include name=\\\"sony.xml\\\"\/>\n\1/\" .repo/manifests/default.xml" >> ${outdir}/apply_patch.sh
    echo "~/bin/repo sync" >> ${outdir}/apply_patch.sh
    echo "" >> ${outdir}/apply_patch.sh
    cat ${outdir}/AOSP_PATCH | sed 's/git fetch https\:\/\/android.googlesource.com\/\([a-zA-Z0-9\/-\_]*\) \(.*\) &amp;&amp; git cherry-pick FETCH_HEAD/git am `ls \$ROOTDIR\/sonyxperiadev\/patches\/\1\/\2\/*.patch`/g' >> orig/${versionName}-${versionNumber}-apply_patch.sh
    cat orig/${versionName}-${versionNumber}-apply_patch.sh | sed 's/cd \(.*[a-zA-Z0-9]+*\).*/cd \1 \&\& git checkout -b \$GIT_BRANCH/g' >> ${outdir}/apply_patch.sh
    echo "" >> ${outdir}/apply_patch.sh
    echo "~/bin/repo status" >> ${outdir}/apply_patch.sh
    echo "~/bin/repo forall -p -c git log --oneline "`cat ${outdir}/AOSP_TAG`"..\$GIT_BRANCH" >> ${outdir}/apply_patch.sh
    echo "" >> ${outdir}/apply_patch.sh
    echo "cd \$ROOTDIR" >> ${outdir}/apply_patch.sh
    chmod +x ${outdir}/apply_patch.sh
    /usr/bin/dos2unix ${outdir}/apply_patch.sh
done

rm -rf orig
