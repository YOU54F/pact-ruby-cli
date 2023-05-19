#!/bin/sh

set -euo >/dev/null

git add Gemfile.lock
bundle exec bump ${RELEASED_GEM_INCREMENT:-minor} --no-commit
PACT_CLI_VERSION=$(ruby -I lib -e "require 'pact/cli/version.rb'; puts Pact::Cli::VERSION")
git add lib/pact/cli/version.rb 

if [ -n "${RELEASED_GEM_NAME}" ] && [ -n "${RELEASED_GEM_VERSION}" ]; then
  git commit -m "feat(gems): pact-cli v$PACT_CLI_VERSION: update ${RELEASED_GEM_NAME} gem to version ${RELEASED_GEM_VERSION}

[ci-skip]
"
else
  updated_gems=$(git diff Gemfile.lock | grep + | grep pact | sed -e "s/+ *//" | ruby -e 'puts ARGF.read.split("\n").join(", ")')
  git commit -m "feat(gems): pact-cli v$PACT_CLI_VERSION: update to ${updated_gems}

[ci-skip]
"
fi

git push
