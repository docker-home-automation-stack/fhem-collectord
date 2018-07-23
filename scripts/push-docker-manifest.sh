#!/bin/bash
set -e

if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then
  exit 0
fi

echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

for variant in dev latest; do
  echo "Creating manifest file homeautomationstack/fhem-collectord:$variant ..."
  docker manifest create homeautomationstack/fhem-collectord:$variant \
    homeautomationstack/fhem-collectord-amd64_linux:$variant \
    homeautomationstack/fhem-collectord-i386_linux:$variant \
    homeautomationstack/fhem-collectord-arm32v5_linux:$variant \
    homeautomationstack/fhem-collectord-arm32v7_linux:$variant \
    homeautomationstack/fhem-collectord-arm64v8_linux:$variant
  docker manifest annotate homeautomationstack/fhem-collectord:$variant homeautomationstack/fhem-collectord-arm32v5_linux:$variant --os linux --arch arm --variant v5
  docker manifest annotate homeautomationstack/fhem-collectord:$variant homeautomationstack/fhem-collectord-arm32v7_linux:$variant --os linux --arch arm --variant v7
  docker manifest annotate homeautomationstack/fhem-collectord:$variant homeautomationstack/fhem-collectord-arm64v8_linux:$variant --os linux --arch arm64 --variant v8
  docker manifest inspect homeautomationstack/fhem-collectord:$variant

  echo "Pushing manifest homeautomationstack/fhem-collectord:$variant to Docker Hub ..."
  docker manifest push homeautomationstack/fhem-collectord:$variant

  echo "Requesting current manifest from Docker Hub ..."
  docker run --rm mplatform/mquery homeautomationstack/fhem-collectord:$variant
done
