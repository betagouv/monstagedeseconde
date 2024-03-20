#!/bin/bash
set -x
set -a
source .env
set +a
target='production'
git remote -vvv | grep $target | grep 'clever'

if [ ! $? -eq 0 ]; then
  echo "missing git remote $target"
  echo "please add $target repo"
  echo "-> git remote add $target $CLEVER_GIT_PRODUCTION_URL"
  exit 1;
fi

SSH_PRIV=~/.ssh/clevercloud-monstage
if [ ! -f "$SSH_PRIV" ]; then
  echo "missing private key to push"
  exit 1;
fi;

git checkout master
if [ ! $? -eq 0 ]; then
  echo 'Wrong branch; you should be on master branch'
  exit 1;
fi;

git pull origin master
git push $target master:master

exit $?
