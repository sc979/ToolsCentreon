#!/bin/bash

# Script to stash and update every Centreon's repos

# Licensed under the Apache License, Version 2.0 (the "License");
# author:sc979
# https://github.com/sc979

# this is a dummy token to replace
token=92c52b3f40f2bde3d9f0bbb874d445b8f585fbf6;

function find_sonar_project() {
  SONAR_PROJECT=( $(ls | grep -i 'sonar-project.properties') )
  if [ -n "$SONAR_PROJECT" ]; then
    return 1;
  fi
}

function launch_sonar() {
  sonar-scanner -Dsonar.login=$token -Dsonar.sonar.verbose=true
}

function colored_output() {
  echo -e "\e[31m\e[1m"$1"\e[0m"
}

REPLY=( $(ls | grep -i 'centreon') )
for i in ${REPLY[@]}; do
  echo ""
  cd $i
  # specific for map project. As three modules are in the same repo
  if [ "$i" == "centreon-map" ]; then
    cd web
    colored_output "Repo to scan : "$i"-web"
    launch_sonar
    cd ../server
    colored_output "Repo to scan : "$i"-server"
    launch_sonar
    cd ../desktop
    colored_output "Repo to scan : "$i"-desktop"
    launch_sonar
    cd ../..
  else
    colored_output "Repo to scan : "$i
    find_sonar_project
    if [ "$?" -eq 1 ]; then
      launch_sonar
    else
      colored_output "no configuration file found"
    fi
    cd ..
  fi
  echo ""
done
echo ""
colored_output "All done"
