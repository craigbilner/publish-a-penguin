#!/usr/bin/env bash

if [[ $TRAVIS_BRANCH == 'master' -a $TRAVIS_TAG == false ]]; then
  # set npm credentials
  echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" > ~/.npmrc

  # bump versions, create change logs, create tags, publish to npm
  MESSAGE=$(printf "chore: Publish %s" $TRAVIS_PULL_REQUEST_BRANCH)
  lerna publish --conventional-commits --yes --concurrency=1 --exact -m $MESSAGE

  # push above changes to git
  git config user.name "Publish Bot"
  git config user.email "publish@ghbot.com"

  git remote set-url origin https://${GH_TOKEN}@github.com/craigbilner/publish-a-penguin.git > /dev/null 2>&1

  git push origin master --tags --quiet > /dev/null 2>&1
fi
