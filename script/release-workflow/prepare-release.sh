#!/bin/sh

set -euo >/dev/null
docker_compose_files=$(find . -name "docker-compose*.yml" -not -name "*test*")

for file in $docker_compose_files; do
  cat $file | sed -e "s~image: pactfoundation/pact-cli:.*~image: pactfoundation/pact-cli:${TAG}~g" > dc-tmp
  mv dc-tmp $file
done

if [[ $DRY_RUN == "true" ]]; then
  echo "Dry run mode enabled - we would be running the following command:"
  echo "bundle exec conventional-changelog version=${TAG} force=true"
else
  bundle exec conventional-changelog version=${TAG} force=true
fi

if [ -n "$VERSION" ]; then
  echo "Updating version - running the following command: bundle exec bump set $VERSION --no-commit"
  bundle exec bump set $VERSION --no-commit
  git add VERSION
else
  echo "Cannot update VERSION file as no VERSION has been specified"
fi

git add CHANGELOG.md
git add docker-compose*

if [[ $DRY_RUN == "true" ]]; then
  echo "Dry run mode enabled - we would be running the following command:"
  echo "git commit -m \"chore(release): version ${TAG}\""
else
  git commit -m "chore(release): version ${TAG}"
fi
