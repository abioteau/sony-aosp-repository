#!/bin/bash
# Script to extract AOSP build instructions for Sony Xperia
# Copyright (C) 2016 Adrien Bioteau - All Rights Reserved
# Permission to copy and modify is granted under the GPLv3 license
# Last revised 09/12/2016

rm -rf sonyxperiadev
mkdir -p sonyxperiadev

# Get AOSP Kitkat Instruction for Sony Mobile web page
mkdir -p orig/kitkat
wget "http://developer.sonymobile.com/open-devices/aosp-build-instructions/how-to-build-aosp-kitkat-for-unlocked-xperia-devices/" -O orig/kitkat/index.html.tmp
cat orig/kitkat/index.html.tmp | sed -n '/<article class="article page-article"/,$p' | sed '/article>/q' > orig/kitkat/index.html
cp orig/kitkat/index.html sonyxperiadev/build-aosp-kitkat-4.4.html
rm orig/kitkat/index.html.tmp

# Get AOSP Lollipop Instruction for Sony Mobile web page
mkdir -p orig/lollipop
wget "http://developer.sonymobile.com/open-devices/aosp-build-instructions/how-to-build-aosp-lollipop-for-unlocked-xperia-devices/" -O orig/lollipop/index.html.tmp
cat orig/lollipop/index.html.tmp | sed -n '/<div class="section overview-section faq-overview-section"/,$p' | sed '/div>/q' > orig/lollipop/index.html
cat orig/lollipop/index.html | sed -n '/<dt id="build-aosp-lollipop-5-1"/,$p' | sed '/\/dd>/q' > sonyxperiadev/build-aosp-lollipop-5.1.html
cat orig/lollipop/index.html | sed -n '/<dt id="build-aosp-lollipop-5-0"/,$p' | sed '/\/dd>/q' > sonyxperiadev/build-aosp-lollipop-5.0.html
rm orig/lollipop/index.html.tmp

# Get AOSP Marshmallow Instruction for Sony Mobile web page
mkdir -p orig/marshmallow
wget "http://developer.sonymobile.com/open-devices/aosp-build-instructions/how-to-build-aosp-marshmallow-for-unlocked-xperia-devices/" -O orig/marshmallow/index.html.tmp
cat orig/marshmallow/index.html.tmp | sed -n '/<div class="section overview-section faq-overview-section"/,$p' | sed '/div>/q' > orig/marshmallow/index.html
cat orig/marshmallow/index.html | sed -n '/<dt id="build-aosp-marshmallow-experimental"/,$p' | sed '/\/dd>/q' > sonyxperiadev/build-aosp-marshmallow-6.0.1.html
cat orig/marshmallow/index.html | sed -n '/<dt id="build-aosp-marshmallow-6-0"/,$p' | sed '/\/dd>/q' > sonyxperiadev/build-aosp-marshmallow-6.0.html
rm orig/marshmallow/index.html.tmp

# Get AOSP Nougat Instruction for Sony Mobile web page
mkdir -p orig/nougat
wget "http://developer.sonymobile.com/open-devices/aosp-build-instructions/how-to-build-aosp-nougat-for-unlocked-xperia-devices/" -O orig/nougat/index.html.tmp
cat orig/nougat/index.html.tmp | sed -n '/<div class="section overview-section faq-overview-section"/,$p' | sed '/div>/q' > orig/nougat/index.html
cat orig/nougat/index.html | sed -n '/<dt id="build-aosp-nougat-7-0"/,$p' | sed '/\/dd>/q' > sonyxperiadev/build-aosp-nougat-7.0.html
rm orig/nougat/index.html.tmp


