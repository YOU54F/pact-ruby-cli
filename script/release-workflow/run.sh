#!/bin/sh

set -euo >/dev/null

script_dir=$(cd "$(dirname $0)" && pwd)

if [ "${GITHUB_ACTIONS:-}" = "true" ]; then
  ${script_dir}/git-configure.sh
  ${script_dir}/docker-login.sh
fi

. ${script_dir}/set-env-vars.sh

DRY_RUN=${DRY_RUN:-}
if [[ $DRY_RUN == "true" ]]; then
  echo "Dry run mode enabled"
  ${script_dir}/validate.sh
  ${script_dir}/prepare-release.sh
else
  ${script_dir}/validate.sh
  ${script_dir}/docker-prepare.sh
  ${script_dir}/docker-build.sh
  ${script_dir}/scan.sh
  ${script_dir}/prepare-release.sh
  ${script_dir}/docker-push.sh
  ${script_dir}/git-push.sh
fi


