#!/bin/bash

# Script to stash and update every Centreon's repos

# Licensed under the Apache License, Version 2.0 (the "License");
# author:sc979
# https://github.com/sc979

#---
## {Print help and usage}
#----
function usage() {
  echo -e "Usage: auto sync all master branches of all Centreon repositories"
  echo -e "  -s\tSave your credentials on all repositories"
  echo -e "  -u\tUpdate all master branches"
  exit 1
}

#---
## {Format messages}
#----
function colored_output() {
  echo -e "\e[31m\e[1m"$1"\e[0m"
}

#---
## {Update the master/main}
#----
function update_master_branch() {
  git fetch --all --tags --prune
  git stash clear && git stash
  git checkout master
  git pull
  git stash apply
}

#---
## {Save credentials localy}
#----
function save_credentials() {
  git config credential.helper store
  git config --global user.name "$1"
  git config --global user.email "$2"
  git fetch
  echo "${1}"
  echo "${3}"
}

USERNAME=""
EMAIL=""
TOKEN=""

#---
## {Process options}
#----
while getopts "suh:" OPTIONS
do
  case ${OPTIONS} in
    s)
      SAVE_CREDENTIALS=1
      ;;
    u)
      SAVE_CREDENTIALS=0
      ;;
    h)
      usage
      exit 0
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

if [ -z "$SAVE_CREDENTIALS" ]; then
  usage
  exit 0
fi

#---
## {Get credentials}
#----
if [ "$SAVE_CREDENTIALS" -eq 1 ]; then
  colored_output "What is your username?"
  echo -en "> "
  read -r USERNAME

  colored_output "What is your email?"
  echo -en "> "
  read -r EMAIL

  colored_output "What is your password or token?"
  echo -en "> "
  read -r TOKEN

  if [ -z "$USERNAME" ] || [ -z "$EMAIL" ] || [ -z "$TOKEN" ]; then
    colored_output "Missing data"
    exit 1
  fi
fi

#---
## {Scan folder and process selected task}
#----
REPLY=( $(ls | grep -i 'centreon') )
for i in ${REPLY[@]}; do
  echo ""
  colored_output "Repo to update : "$i
  cd $i
  if [ "$SAVE_CREDENTIALS" -eq "1" ]; then
    save_credentials $USERNAME $MAIL $TOKEN
  else
    update_master_branch
  fi
  cd ..
  colored_output "OK"
done
echo ""
colored_output "All done"
