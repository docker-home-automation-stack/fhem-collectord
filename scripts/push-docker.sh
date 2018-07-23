#!/bin/bash
set -e

cd "$(readlink -f "$(dirname "$BASH_SOURCE")")"/..

if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then
  echo -e "\n\nThis build is related to pull request ${TRAVIS_PULL_REQUEST} and will not be published to Docker Hub."
  exit 0
fi

echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
docker push "homeautomationstack/fhem-collectord-$LABEL"
RET=$?

if [ -s ./failed_variants ]; then
  echo -e "\n\nThe following variants failed integration test and where not published:"
  cat ./failed_variants
  exit 1
fi

exit $RET
