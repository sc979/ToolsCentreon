#!/bin/bash
# Script to launch vncviewer for each acceptance test launched

# Licensed under the Apache License, Version 2.0 (the "License");
# author:sc979
# https://github.com/sc979

echo "Warning -> you'll need to close by yourself the script (Ctrl+C)"

while true; do
  echo
  i="0"
  INSTANCE_ID=""
  echo "Waiting : acceptance test not running yet"
  #waiting for the docker launching the acceptance tests to be ready
  while [ -z "$INSTANCE_ID" ]; do
    echo "${i} sec..."
    INSTANCE_ID="$(docker ps | grep selenium | cut -c1-4)"
    i=$[i+3]
    sleep 3
  done
  #Getting docker information and launching vnc on it
  echo
  docker ps
  echo
  echo "Docker instance short ID : "${INSTANCE_ID}
  DOCKER_IP="$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${INSTANCE_ID})"
  echo "Docker IP : "${DOCKER_IP}
  echo
  echo "launching VncViewer"
  vncviewer ${DOCKER_IP}:5900 -p ./passwd
done
