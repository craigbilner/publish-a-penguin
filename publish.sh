#!/usr/bin/env bash
set -e

echo "Running publish script tb"

echo $(printf "TRAVIS_BRANCH %s" $TRAVIS_BRANCH)
echo $(printf "TRAVIS_TAG %s" $TRAVIS_TAG)
echo $(printf "TRAVIS_PULL_REQUEST %s" $TRAVIS_PULL_REQUEST)

if [[ $TRAVIS_BRANCH == 'master' && !$TRAVIS_TAG && $TRAVIS_PULL_REQUEST == 'false' ]]
then
  # set npm credentials
  echo "Setting up npm"
  echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" > ~/.npmrc

  # set up git
  git config user.name "Publish Bot"
  git config user.email "publish@ghbot.com"

  git remote set-url origin https://${GH_TOKEN}@github.com/craigbilner/publish-a-penguin.git > /dev/null 2>&1
  git checkout master

  # check we're at the tip of master
  TIP_COMMIT=$(git rev-parse HEAD)
  echo $(printf "Travis commit: %s, Head commit: %s" $TRAVIS_COMMIT $TIP_COMMIT)

  if [[ $TIP_COMMIT != $TRAVIS_COMMIT ]]
  then
    echo "Not on the tip of master!"
    exit 0
  fi

  # make sure we only publish if we are at the head of master

  # bump versions, create change logs, create tags, publish to npm
  PR_MSG=$(git log --pretty=format:"%s" -1)
  MESSAGE=$(printf "chore: Publish %s" $PR_MSG)
  echo $MESSAGE
  lerna publish --conventional-commits --yes --concurrency=1 --exact -m $MESSAGE

  # push above changes to git
  echo "Pushing to master"
  git push origin master --tags --quiet > /dev/null 2>&1
else
  echo "Doing nothing"
fi
