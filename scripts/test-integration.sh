#!/bin/bash

cd "$(readlink -f "$(dirname "$BASH_SOURCE")")"/..

echo -e "\n\n"
docker images homeautomationstack/*
rm -rf ./failed_variants
RETURNCODE=1

for ID in $( docker images homeautomationstack/* | grep 'homeautomationstack/*' | awk '{print $3}' ); do
  echo "Booting up container for variant $ID ..."
  CONTAINER=$( docker run -d -ti $ID )
  docker container ls | grep 'homeautomationstack/.*'

  echo -ne "\nWaiting for container ..."
  sleep 3
  bootstate="created"
  until [ $bootstate != "created" ]; do
    bootstate=$( docker inspect --format="{{json .State}}" $CONTAINER 2>/dev/null | jq -r .Status )
    echo -n " ."
    sleep 3
  done
  if [ -z "$bootstate" ]; then
    RETURNCODE=3
    status="undefined-error"
  elif [ "$bootstate" != "running" ]; then
    RETURNCODE=2
    status=$bootstate
  fi

  if [ -z "$status" ]; then
    echo -ne "\nWaiting for health status report ..."
    healthstate="starting"
    until [ $healthstate != "starting" ]; do
      healthstate=$( docker inspect --format="{{json .State}}" $CONTAINER 2>/dev/null | jq -r .Health.Status )
      echo -n " ."
      sleep 3
    done
    if [ -n "$healthstate" ] && [ "$healthstate" == "healthy" ]; then
      status="OK"
    elif [ -n "$healthstate" ] && [ "$healthstate" != "null" ]; then
      status=$healthstate
    else
      echo " not defined"
      status="OK"
    fi
  fi

  if [ "$status" != "OK" ]; then
    echo -e "\nImage $ID did come up with unexpected state "$status". Integration test FAILED!\n\n"
    docker logs $CONTAINER
    docker container rm $CONTAINER --force --volumes 2>&1>/dev/null
    docker rmi $ID >/dev/null
    echo "$ID $status" >> ./failed_variants
  else
    echo -e "\nImage $ID integration test PASSED.\n\n"
    docker container rm $CONTAINER --force --volumes 2>&1>/dev/null
    RETURNCODE=0
  fi
done

exit $RETURNCODE
