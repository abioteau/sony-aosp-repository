#!/bin/bash
# Script to extract AOSP build instructions for Sony Xperia
# Copyright (C) 2016 Adrien Bioteau - All Rights Reserved
# Permission to copy and modify is granted under the GPLv3 license
# Last revised 09/12/2016

rm -rf sonyxperiadev
mkdir -p sonyxperiadev

# Get AOSP Kitkat Instruction for Sony Mobile web page
mkdir -p orig/kitkat
wget "http://developer.sonymobile.com/open-devices/aosp-build-instructions/how-to-build-aosp-kitkat-for-unlocked-xperia-devices/" -O orig/kitkat/index.html
cat orig/kitkat/index.html | sed -n '/<article class="article page-article"/,$p' | sed '/article>/q' > sonyxperiadev/build-aosp-kitkat-4.4.html
rm -rf orig/kitkat

# Get AOSP Lollipop Instruction for Sony Mobile web page
mkdir -p orig/lollipop
wget "http://developer.sonymobile.com/open-devices/aosp-build-instructions/how-to-build-aosp-lollipop-for-unlocked-xperia-devices/" -O orig/lollipop/index.html.tmp
cat orig/lollipop/index.html.tmp | sed -n '/<div class="section overview-section faq-overview-section"/,$p' | sed '/div>/q' > orig/lollipop/index.html
cat orig/lollipop/index.html | sed -n '/<dt id="build-aosp-lollipop-5-1"/,$p' | sed '/\/dd>/q' > sonyxperiadev/build-aosp-lollipop-5.1.html
cat orig/lollipop/index.html | sed -n '/<dt id="build-aosp-lollipop-5-0"/,$p' | sed '/\/dd>/q' > sonyxperiadev/build-aosp-lollipop-5.0.html
rm -rf orig/lollipop

# Get AOSP Marshmallow Instruction for Sony Mobile web page
mkdir -p orig/marshmallow
wget "http://developer.sonymobile.com/open-devices/aosp-build-instructions/how-to-build-aosp-marshmallow-for-unlocked-xperia-devices/" -O orig/marshmallow/index.html.tmp
cat orig/marshmallow/index.html.tmp | sed -n '/<div class="section overview-section faq-overview-section"/,$p' | sed '/div>/q' > orig/marshmallow/index.html
cat orig/marshmallow/index.html | sed -n '/<dt id="build-aosp-marshmallow-experimental"/,$p' | sed '/\/dd>/q' > sonyxperiadev/build-aosp-marshmallow-6.0.1.html
cat orig/marshmallow/index.html | sed -n '/<dt id="build-aosp-marshmallow-6-0"/,$p' | sed '/\/dd>/q' > sonyxperiadev/build-aosp-marshmallow-6.0.html
rm -rf orig/marshmallow

# Get AOSP Nougat Instruction for Sony Mobile web page
mkdir -p orig/nougat
wget "http://developer.sonymobile.com/open-devices/aosp-build-instructions/how-to-build-aosp-nougat-for-unlocked-xperia-devices/" -O orig/nougat/index.html.tmp
cat orig/nougat/index.html.tmp | sed -n '/<div class="section overview-section faq-overview-section"/,$p' | sed '/div>/q' > orig/nougat/index.html
cat orig/nougat/index.html | sed -n '/<dt id="build-aosp-nougat-7-0"/,$p' | sed '/\/dd>/q' > sonyxperiadev/build-aosp-nougat-7.0.html
rm -rf orig/nougat

buildInstructions=`find sonyxperiadev/*.html`

for file in ${buildInstructions};
do
	versionName=`echo ${file} | sed 's/sonyxperiadev\/build-aosp-//g' | sed 's/[0-9.]//g' | sed 's/.html//g'`
	versionNumber=`echo ${file} | sed 's/sonyxperiadev\/build-aosp-[a-z]*-//g' | sed 's/.html//g'`
	outdir=sonyxperiadev/${versionName}/${versionNumber}

	mkdir -p ${outdir}

	grep "repo init" ${file} | grep -o -E "android-[0-9._r]*" > ${outdir}/AOSP_TAG

	cat ${file} |
		sed 's/<br \/>//g' |
		sed 's/&lt;/\</g' |
		sed 's/&quot;/\"/g' |
		sed 's/&gt;/\>/g' |
		sed 's/.*<?xml version/<?xml version/' |
		sed 's/\/manifest>.*/\/manifest>/' |
		sed -n '/<?xml version/,$p' | sed '/\/manifest>/q' > ${outdir}/sony.xml

	cat ${file} |
		sed 's/<br \/>//g' |
		sed 's/.*cd /cd /g' |
		sed 's/\/li>.*/\/li>/g' |
		sed -n '/cd [build|hardware|external|system|packages]/,$p' | sed '/\/li\>/q' |
		sed 's/<\/pre>//g' |
		sed 's/<\/li>//g' |
		sed 's/<\/code>//g' > ${outdir}/AOSP_PATCH
done
