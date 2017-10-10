#!/bin/sh
#!/bin/bash
# Script to commit and push
# Copyright (C) 2017 Adrien Bioteau - All Rights Reserved
# Permission to copy and modify is granted under the GPLv3 license
# Last revised 01/31/2017

setup_git() {
    git config --global user.email "adrien.bioteau@gmail.com"
    git config --global user.name "Adrien Bioteau"
}

commit_sonyxperiadev_files() {
    git checkout master
    git add sonyxperiadev
    git status
    git commit --message "Sony Xperia AOSP build instructions `date +%m/%d/%Y`"
}

upload_files() {
    if [ ! -z $2 ] && [ -d $2 ]
    then
        cd $2
        git remote add origin-travis https://${GH_TOKEN}@github.com/$1 > /dev/null 2>&1
        git push --quiet --tags --set-upstream origin-travis `git rev-parse --abbrev-ref HEAD`
        cd -
    fi
}

setup_git
commit_sonyxperiadev_files
upload_files abioteau/sony-aosp-repository.git .
upload_files abioteau/vendor_sony.git vendor/sony
upload_files abioteau/vendor_sony_loire.git vendor/sony/loire
upload_files abioteau/vendor_sony_tone.git vendor/sony/tone
upload_files abioteau/vendor_sony_yoshino.git vendor/sony/yoshino
