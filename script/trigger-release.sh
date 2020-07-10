#!/bin/bash

output=$(curl -v -X POST https://api.github.com/repos/pact-foundation/pact-ruby-cli/dispatches \
      -H 'Accept: application/vnd.github.everest-preview+json' \
      -H "Authorization: Bearer $GITHUB_ACCESS_TOKEN" \
      -d '{"event_type": "gem-released"}' 2>&1)

echo "$output" | sed  "s/${GITHUB_ACCESS_TOKEN}/****/g"

if  ! echo "${output}" | grep "HTTP\/1.1 204" > /dev/null; then
  echo "$output" | sed  "s/${GITHUB_ACCESS_TOKEN}/****/g"
  echo "Failed to do the thing"
  exit 1
fi

