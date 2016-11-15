#!/bin/sh

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
  git remote add origin-travis https://${GH_TOKEN}@github.com/abioteau/sony-aosp-repository.git > /dev/null 2>&1
  git push --quiet --set-upstream origin-travis master
}

setup_git
commit_sonyxperiadev_files
upload_files
