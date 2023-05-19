#!/bin/sh

set -euo >/dev/null

## Update the version of the CLI in the Gemfile.lock and lib/pact/cli/version.rb
## bundle exec bump updates VERSION instead of pact/cli/version.rb
## so we store it, update our bundle, and then write it back
## the PACT_CLI_DOCKER_VERSION is our Docker semantic tag
PACT_CLI_DOCKER_VERSION=$(cat VERSION)
rm VERSION
gem install bump -v 0.9
bump ${RELEASED_GEM_INCREMENT:-minor} --no-commit
PACT_CLI_VERSION=$(ruby -I lib -e "require 'pact/cli/version.rb'; puts Pact::Cli::VERSION")

if [ -n "${RELEASED_GEM_NAME:-}" ] && [ -n "${RELEASED_GEM_VERSION:-}" ]; then
  gem install ${RELEASED_GEM_NAME} -v ${RELEASED_GEM_VERSION}
  bundle update ${RELEASED_GEM_NAME}
else
  bundle update
fi

## Make sure we write our original PACT_CLI_DOCKER_VERSION back
echo $PACT_CLI_VERSION > VERSION