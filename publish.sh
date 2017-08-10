#!/usr/bin/env bash
set -e

echo $(printf "Running publish script tb: %s, tt: %s, tpr: %s" $TRAVIS_BRANCH $TRAVIS_TAG $TRAVIS_PULL_REQUEST)

if [[ $TRAVIS_BRANCH == 'master' && $TRAVIS_TAG = 'false' && -z $TRAVIS_PULL_REQUEST ]]
then
  echo "yes! 1"
fi

if [[ $TRAVIS_BRANCH == 'master' && -z $TRAVIS_TAG && -z $TRAVIS_PULL_REQUEST ]]
then
  echo "yes! 2"
fi

if [[ $TRAVIS_BRANCH == 'master' && $TRAVIS_TAG == 'false' && -z $TRAVIS_PULL_REQUEST ]]
then
  echo "yes! 3"
fi

if [[ $TRAVIS_BRANCH == 'master' && $TRAVIS_TAG = '' && -z $TRAVIS_PULL_REQUEST ]]
then
  # set npm credentials
  echo "Setting up npm"
  echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" > ~/.npmrc

  # set up git
  git config user.name "Publish Bot"
  git config user.email "publish@ghbot.com"

  git remote set-url origin https://${GH_TOKEN}@github.com/craigbilner/publish-a-penguin.git > /dev/null 2>&1
  git checkout master

  # make sure we only publish if we are at the head of master

  # bump versions, create change logs, create tags, publish to npm
  MESSAGE=$(printf "chore: Publish %s" $TRAVIS_PULL_REQUEST_BRANCH)
  echo $MESSAGE
  lerna publish --conventional-commits --yes --concurrency=1 --exact -m $MESSAGE

  # push above changes to git
  echo "Pushing to master"
  git push origin master --tags --quiet > /dev/null 2>&1
else
  echo "Doing nothing"
fi
