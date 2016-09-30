#!/bin/bash
# Script to extract AOSP build instructions for Sony Xperia
# Copyright (C) 2016 Adrien Bioteau - All Rights Reserved
# Permission to copy and modify is granted under the GPLv3 license
# Last revised 09/12/2016

mkdir -p sonyxperiadev

# Get AOSP Kitkat Instruction for Sony Mobile web page
mkdir -p orig/kitkat
wget "http://developer.sonymobile.com/open-devices/aosp-build-instructions/how-to-build-aosp-kitkat-for-unlocked-xperia-devices/" -O orig/kitkat/index.html
cat orig/kitkat/index.html | sed -n '/<article class="article page-article"/,$p' | sed '/article>/q' > sonyxperiadev/build-aosp-kitkat-4.4.html

# Get AOSP Lollipop Instruction for Sony Mobile web page
mkdir -p orig/lollipop
wget "http://developer.sonymobile.com/open-devices/aosp-build-instructions/how-to-build-aosp-lollipop-for-unlocked-xperia-devices/" -O orig/lollipop/index.html.tmp
cat orig/lollipop/index.html.tmp | sed -n '/<div class="section overview-section faq-overview-section"/,$p' | sed '/div>/q' > orig/lollipop/index.html
cat orig/lollipop/index.html | sed -n '/<dt id="build-aosp-lollipop-5-1"/,$p' | sed '/\/dd>/q' > sonyxperiadev/build-aosp-lollipop-5.1.html
cat orig/lollipop/index.html | sed -n '/<dt id="build-aosp-lollipop-5-0"/,$p' | sed '/\/dd>/q' > sonyxperiadev/build-aosp-lollipop-5.0.html

# Get AOSP Marshmallow Instruction for Sony Mobile web page
mkdir -p orig/marshmallow
wget "http://developer.sonymobile.com/open-devices/aosp-build-instructions/how-to-build-aosp-marshmallow-for-unlocked-xperia-devices/" -O orig/marshmallow/index.html.tmp
cat orig/marshmallow/index.html.tmp | sed -n '/<div class="section overview-section faq-overview-section"/,$p' | sed '/div>/q' > orig/marshmallow/index.html
cat orig/marshmallow/index.html | sed -n '/<dt id="build-aosp-marshmallow-experimental"/,$p' | sed '/\/dd>/q' > sonyxperiadev/build-aosp-marshmallow-6.0.1.html
cat orig/marshmallow/index.html | sed -n '/<dt id="build-aosp-marshmallow-6-0"/,$p' | sed '/\/dd>/q' > sonyxperiadev/build-aosp-marshmallow-6.0.html

# Get AOSP Nougat Instruction for Sony Mobile web page
mkdir -p orig/nougat
wget "http://developer.sonymobile.com/open-devices/aosp-build-instructions/how-to-build-aosp-nougat-for-unlocked-xperia-devices/" -O orig/nougat/index.html.tmp
cat orig/nougat/index.html.tmp | sed -n '/<div class="section overview-section faq-overview-section"/,$p' | sed '/div>/q' > orig/nougat/index.html
cat orig/nougat/index.html | sed -n '/<dt id="build-aosp-nougat-7-0"/,$p' | sed '/\/dd>/q' > sonyxperiadev/build-aosp-nougat-7.0.html

#For each AOSP build instructions
buildInstructions=`find sonyxperiadev/build-aosp-*.html`
for file in ${buildInstructions};
do
	versionName=`echo ${file} | sed 's/sonyxperiadev\/build-aosp-//g' | sed 's/[0-9.]//g' | sed 's/.html//g'`
	versionNumber=`echo ${file} | sed 's/sonyxperiadev\/build-aosp-[a-z]*-//g' | sed 's/.html//g'`
	outdir=sonyxperiadev/${versionName}/${versionNumber}

	mkdir -p ${outdir}

	# Extract AOSP reference tag
	grep "repo init" ${file} | grep -o -E "android-[0-9._r]*" > ${outdir}/AOSP_TAG

	# Extract Sony repository manifest
	cat ${file} | \
		sed 's/<br \/>//g' | \
		sed 's/&lt;/\</g' | \
		sed 's/&quot;/\"/g' | \
		sed 's/&gt;/\>/g' | \
		sed 's/.*<?xml version/<?xml version/g' | \
		sed 's/\/manifest>.*/\/manifest>/g' | \
		sed -n '/<?xml version/,$p' | sed '/\/manifest>/q' > ${outdir}/sony.xml

	# Extract list of AOSP patches
	cat ${file} | \
		sed 's/<br \/>//g' | \
		sed 's/.*cd /cd /g' | \
		sed 's/\/li>.*/\/li>/g' | \
		sed -n '/cd [build|hardware|external|system|packages]/,$p' | sed '/\/li\>/q' | \
		sed 's/<\/pre>//g' | \
		sed 's/<\/li>//g' | \
		sed 's/<\/code>//g' > ${outdir}/AOSP_PATCH

	# Get AOSP patches
	echo "BASEDIR=`pwd`" > orig/${versionName}-${versionNumber}-patch.sh
	chmod +x orig/${versionName}-${versionNumber}-patch.sh
	grep -o "git fetch[^&]*" ${outdir}/AOSP_PATCH | sed 's/&amp;//g' | \
	sed 's/git fetch https\:\/\/android.googlesource.com\/\([a-zA-Z0-9\/-\_]*\) \(.*\)/mkdir -p \$\{BASEDIR\}\/orig\/\1 \&\& git clone https\:\/\/android.googlesource.com\/\1 \$\{BASEDIR\}\/orig\/\1/' >> orig/${versionName}-${versionNumber}-patch.sh
	grep -o "git fetch[^&]*" ${outdir}/AOSP_PATCH | sed 's/&amp;//g' | \
	sed 's/git fetch https\:\/\/android.googlesource.com\/\([a-zA-Z0-9\/-\_]*\) \(.*\)/cd \$\{BASEDIR\}\/orig\/\1 \&\& git fetch origin \2 \&\& mkdir -p \$\{BASEDIR\}\/sonyxperiadev\/patches\/\1\/\2 \&\& git format-patch FETCH_HEAD^! -o \$\{BASEDIR\}\/sonyxperiadev\/patches\/\1\/\2 \&\& cd -/' >> orig/${versionName}-${versionNumber}-patch.sh
	./orig/${versionName}-${versionNumber}-patch.sh
done

# Get AOSP software binaries for Sony Mobile web page
mkdir -p orig/binaries
wget "http://developer.sonymobile.com/downloads/software-binaries/" -O orig/binaries/index.html
cat orig/binaries/index.html | sed -n '/<div class="section downloads-section"/,$p' | sed '/div>/q' > sonyxperiadev/software-binaries.html

mkdir -p sonyxperiadev/binaries
cat orig/binaries/index.html | sed -n '/<tbody/,$p' | sed '/\/tbody>/q' > orig/binaries/body.html
binariesNumber=`cat orig/binaries/body.html | grep -c "<tr>"`
counter=0
while [[ ${counter} < ${binariesNumber} ]];
do
	cat orig/binaries/body.html | sed -n '/<tr/,$p' | sed '/\/tr>/q' > orig/binaries/body-${counter}.html

	grep -o 'http://dl-developer.sonymobile.com/eula[^"]*' orig/binaries/body-${counter}.html | grep AOSP | \
		xargs -I {} wget {} -O orig/binaries/eula-${counter}.html
	grep -o "restricted/[^\']*" orig/binaries/eula-${counter}.html | sed 's/\?param=//g' | sed 's/restricted\///g' | \
		xargs -I {} wget -c --no-cookies --header "Cookie: dw_accepted=true" "http://dl-developer.sonymobile.com/eula/restricted/"{} -O sonyxperiadev/binaries/{}

	cat orig/binaries/body.html | sed -n '/\/tr>/,$p' | sed '1s/<\/tr>//g' > orig/binaries/body.html.tmp
	cp orig/binaries/body.html.tmp orig/binaries/body.html
	counter=$((counter+1))
done

# Get list of devices and ressources for Sony Mobile web page
wget "http://developer.sonymobile.com/open-devices/list-of-devices-and-resources/" -O orig/list.html
cat orig/list.html | sed -n '/<article class="article page-article"/,$p' | sed '/article>/q' > sonyxperiadev/list-of-devices-and-resources.html

# Get latest update for Sony Mobile web page
wget "http://developer.sonymobile.com/open-devices/latest-updates/" -O orig/latest.html
cat orig/latest.html | sed -n '/<article class="article page-article"/,$p' | sed '/article>/q' > sonyxperiadev/latest-updates.html

rm -rf orig
