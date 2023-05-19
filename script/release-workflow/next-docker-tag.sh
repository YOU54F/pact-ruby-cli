#!/bin/sh

set -eu

gem_version_from_gemfile_lock() {
  grep "pact_broker (" pact_broker/Gemfile.lock | awk -F '[()]' '{print $2}'
}

gem_version=$(ruby -I lib -e "require 'pact/cli/version.rb'; puts Pact::Cli::VERSION")
echo "gem_version:" $gem_version
existing_tags=$(git tag)
echo "existing_tags:" $existing_tags
existing_release_numbers_for_current_gem_version=$(echo "$existing_tags" | grep "${gem_version}\." | sed 's/'${gem_version}'\.//g' | grep -E "^[0-9]+$" | cat)
echo "existing_release_numbers_for_current_gem_version:" $existing_release_numbers_for_current_gem_version

if [ -n "${existing_release_numbers_for_current_gem_version}" ]; then
  echo "no existing_release_numbers_for_current_gem_version:"
  last_release_number=$(printf "0\n${existing_release_numbers_for_current_gem_version}" | sort -g | tail -1)
  echo "last_release_number:" $last_release_number
  next_release_number=$(( $last_release_number + 1 ))
  echo "next_release_number:" $next_release_number
else
  echo "existing_release_numbers_for_current_gem_version:"
  next_release_number=0
  echo "next_release_number:" $next_release_number
fi

echo "constructing tag tag="${gem_version}.${next_release_number}""
RELEASE=${next_release_number}
tag="${gem_version}.${next_release_number}"
echo $tag
