#!/bin/bash
set -e

cd "$(readlink -f "$(dirname "$BASH_SOURCE")")"/..

base="homeautomationstack/fhem-collectord-$LABEL"
dockerfile="./Dockerfile.${ARCH}"

if [ ! -s $dockerfile ]; then
  echo "ERROR: No Dockerfile found for architecture ${ARCH}."
  exit 2
fi

if [ $ARCH != "amd64" ] && [ $ARCH != "i386" ]; then
  echo "Starting QEMU environment for multi-arch build ..."
  docker run --rm --privileged multiarch/qemu-user-static:register --reset
fi

branch=""
[ "${TRAVIS_BRANCH}" != "master" ] && [ "${TRAVIS_BRANCH}" != "${TRAVIS_TAG}" ] && branch=".${TRAVIS_BRANCH}"
variant=$(git describe --long --tags --dirty --always)$branch

echo -e "\n\nNow building variant $variant ...\n\n"

# Only run build if not existing on Docker hub yet
function docker_tag_exists() {
  TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${DOCKER_USER}'", "password": "'${DOCKER_PASS}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)
  EXISTS=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/$1/tags/?page_size=10000 | jq -r "[.results | .[] | .name == \"$2\"] | any")
    test $EXISTS = true
}
if docker_tag_exists $base $variant; then
  echo "Variant $variant already existig on Docker Hub - skipping build."
  continue
fi

# Detect rolling tag for this build
if [ "${TRAVIS_BRANCH}" == "master" ] || [ "${TRAVIS_BRANCH}" == "${TRAVIS_TAG}" ]; then
  tag="latest"
else
  tag="${TRAVIS_BRANCH}"
fi

# Check for image availability on Docker hub registry
if docker_tag_exists $base $tag; then
  echo "Found prior build $base:$tag on Docker Hub registry"
  cache_tag=$tag
else
  echo "No prior build found for $base:$tag on Docker Hub registry"
fi

# build or 3 main variants
if [ -n "$tag" ]; then

  # If we have a revision in the Docker registry, use it as cache
  if [ -n "$cache_tag" ]; then
    echo "Loading image into cache ..."
    docker pull "$base:$cache_tag"
    docker build --cache-from "$base:$cache_tag" -t "$base:$variant" -f "$dockerfile" .

  # no existing image in registry
  else
    docker build -t "$base:$variant" -f "$dockerfile" .
  fi

  # Add rolling tag to this build
  docker tag "$base:$variant" "$base:$tag"

# build any other branch
else
  docker build -t "$base:$variant" -f "$dockerfile" .
fi

exit 0
