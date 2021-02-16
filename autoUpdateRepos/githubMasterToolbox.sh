#!/bin/bash

# Script to stash and update every Centreon's repos

# Licensed under the Apache License, Version 2.0 (the "License");
# author:sc979
# https://github.com/sc979

#---
## {Format messages}
#----
function success_output() {
  echo -e "\e[32m\e[1m"$1"\e[0m"
}
function error_output() {
  echo -e "\e[31m\e[1m"$1"\e[0m"
}
function query_output() {
  echo -e "\e[34m\e[1m"$1"\e[0m"
}
function query_info() {
  echo -e "\e[35m\e[1m"$1"\e[0m"
}

#---
## {Print help and usage}
#----
function usage() {
  success_output "\nToolbox to automate task on multiple Centreon repositories"
  echo -e "Usage: "
  echo -e "  -s\tSave your credentials on all repositories"
  echo -e "  -u\tUpdate all master branches"
  echo -e "  -c\tClean deleted branches on the distant"
  echo -e "  -v\tClean vendor folders from all projects"
  #echo -e "  -d\tDeploy file to all repos"
  #echo -e "  -p\tCreate same branch on each repo and push them"
  echo ""
  exit 1
}

#---
## {Purge old branches}
#---
function clean_old_branches() {
  query_info "Search for old branches"
  git fetch --all --tags --prune
  if [[ $? -eq 0 ]]; then
    query_output "Old branches removed"
  fi;
}

#---
## {Update the master/main}
#----
function update_master_branch() {
  query_info "Search for commits"
  git fetch --all --tags
  git stash clear && git stash
  git checkout master
  git pull
  git stash apply
  query_output "Repository updated"
}

#---
## {Save credentials locally}
#----
function save_credentials() {
  USERNAME="$1"
  EMAIL="$2"
  TOKEN="$3"

  git config credential.helper store
  git config --global user.name "$1"
  git config --global user.email "$2"
  git fetch
  echo "${USERNAME}"
  echo "${TOKEN}"
}

#---
## {Deploy file on all repos}
#---
function deploy_file() {
  BRANCH_NAME="$1"
  COMMIT_MESSAGE="$2"
  FILE_TO_DEPLOY="$3"

  git stash clear && git stash
  git checkout master
  git pull
  git checkout "$BRANCH_NAME"

  if [ "$?" -eq 1 ]; then
    git checkout -b "$BRANCH_NAME"
  fi
  cp "$FILE_TO_DEPLOY" ./
  git commit -a -m "$COMMIT_MESSAGE"
  git checkout master
  git stash apply && git stash clear
}

#---
## {Multiple branches push from HEAD to distant}
#---
function push_branch() {
  BRANCH_NAME="$1"

  git checkout "$BRANCH_NAME"
  if [ "$?" -eq 0 ]; then
    git push origin "$BRANCH_NAME"
  else
    error_output "Cannot checkout : $BRANCH_NAME"
    exit 1;
  fi
}

#
## {Delete vendor folder from projects}
#
function delete_vendor_folders() {
  query_info "Search for vendor folder"
  VENDOR_PATH=`find ./ -name "vendor"`
  for i in ${VENDOR_PATH[@]}; do
    if [[ $i == "./vendor" || $i == "./server/vendor" || $i == "./web/app/vendor" ]]; then
      rm -rf "$i"
      if [[ $? -eq 0 ]]; then
        query_output "Folder removed : $i"
      fi
  fi
done
}

#---
## {Variables}
#---
SAVE_CREDENTIALS=0
UPDATE=0
DEPLOY=0
PUSH=0
CLEAN_BRANCHES=0
USERNAME=""
EMAIL=""
TOKEN=""
BRANCH_NAME=""
COMMIT_MESSAGE=""
FILE_TO_DEPLOY=""
CLEAN_VENDOR=0

#---
## {Process options}
#----

# Removing WIP d & p options
#while getopts "sucvdph" OPTIONS
while getopts "sucvh" OPTIONS
do
  case ${OPTIONS} in
    s)
      SAVE_CREDENTIALS=1
      ## Get credentials
      query_output "What is your username?"
      echo -en "> "
      read -r USERNAME
      query_output "What is your email?"
      echo -en "> "
      read -r EMAIL
      query_output "What is your password or token?"
      echo -en "> "
      read -r TOKEN
      if [[ -z $USERNAME || -z $EMAIL || -z $TOKEN ]]; then
        error_output "Missing data"
        exit 1
      fi
      ;;
    u)
      UPDATE=1
      ;;
    c)
      CLEAN_BRANCHES=1
      ;;
    v)
      CLEAN_VENDOR=1
      ;;
    d)
      DEPLOY=1
      query_output "What is the branch's name?"
      echo -en "> "
      read -r BRANCH_NAME
      query_output "What is the commit message?"
      echo -en "> "
      read -r COMMIT_MESSAGE
      query_output "What is the file to deploy?"
      echo -en "> "
      read -r FILE_TO_DEPLOY
      if [[ -z $BRANCH_NAME || -z $COMMIT_MESSAGE || -z $FILE_TO_DEPLOY ]]; then
        error_output "Missing data"
        exit 1
      fi
      ;;
    p)
      PUSH=1
      query_output "What is the branch's name?"
      echo -en "> "
      read -r BRANCH_NAME
      if [[ -z $BRANCH_NAME ]]; then
        error_output "Missing data"
        exit 1
      fi
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

if [[ $SAVE_CREDENTIALS -eq 0 && $UPDATE -eq 0 && $DEPLOY -eq 0 && $PUSH -eq 0 && CLEAN_BRANCHES -eq 0 && CLEAN_VENDOR -eq 0 ]]; then
  usage
  exit 1
fi

#---
## {Scan folder and process selected task}
#----

REPLY=( $(ls | grep -i 'centreon') )
for i in ${REPLY[@]}; do
  echo ""
  success_output "Repository : $i"
  cd $i
  if [[ $SAVE_CREDENTIALS -eq 1 ]]; then
    save_credentials "$USERNAME" "$MAIL" "$TOKEN"
  else
    if [[ $CLEAN_VENDOR -eq 1 ]]; then
      delete_vendor_folders
    fi
    if [[ $CLEAN_BRANCHES -eq 1 ]]; then
      clean_old_branches
    fi
    if [[ $UPDATE -eq 1 ]]; then
      update_master_branch
    fi
    if [[ $DEPLOY -eq 1 ]]; then
      deploy_file  "$BRANCH_NAME" "$COMMIT_MESSAGE" "$FILE_TO_DEPLOY"
    fi
    if [[ $PUSH -eq 1 ]]; then
      push_branch "$BRANCH_NAME"
    fi
  fi
  cd ..
  success_output "OK"
done
echo ""
success_output "All done"
