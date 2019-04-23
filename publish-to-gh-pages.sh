#!/bin/bash
set -ev
#git clone https://${GH_REF} .deploy_git
#cd .deploy_git
#git checkout master
#cd ../
#mv .deploy_git/.git/ ./public/
cd ./public
git init
git config user.name  "pickou"
git config user.email "472179216@qq.com" 
# add commit timestamp
git add .
git status
ls
git commit -m "Travis CI Auto Builder at `date +"%Y-%m-%d %H:%M"`"
git push --force "https://${travis_gh_token}@${GH_REF}" master:master
#git push --force --quiet "https://${travis_gh_token}@${GH_REF}" master:master
#git push --force --quiet "https://hadronw:${Travis_co_token}@${CO_REF}" master:master