#!/bin/sh

set -euo >/dev/null

git add Gemfile.lock
git add VERSION lib/pact/cli/version.rb
git commit -m "chore(release): version ${TAG}"
git tag -a "${TAG}" -m "chore(release): version ${TAG}"
git push origin ${TAG}
git push origin master
