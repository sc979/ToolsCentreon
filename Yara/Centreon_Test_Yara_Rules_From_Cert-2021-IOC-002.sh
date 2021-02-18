#!/bin/bash
#
# Copyright 2005 - 2021 Centreon (https://www.centreon.com/)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# For more information : security@centreon.com or contact@centreon.com
#

#---
## {Format messages}
#---
function success_message() {
  echo -e "\e[32m\e[1m$1\e[0m\n"
}
function error_message() {
  echo -e "\e[31m\e[1m$1\e[0m"
}
function output_message() {
  echo -e "\e[35m\e[1m$1\e[0m"
}
function info_message() {
  echo -e "\e[34m\e[1m$1\e[0m"
}
function normal_message() {
  echo -e "\e[0m$1"
}

#---
## {Print description and usage}
#---
function usage() {
  #Description
  normal_message ""
  normal_message "Description:"
  normal_message ""
  info_message "\tThis script will use the Yara software and execute each of the rules provided by the ANSSI"
  info_message "\tto test your platform against modifications made by fobushell or exaramel"
  normal_message ""
  normal_message "\tThe rules were provided the February 26, 2021 by the ANSSI and are available here:"
  normal_message "\thttp://www.cert.ssi.gouv.fr/uploads/CERTFR-2021-IOC-002-YARA.zip"
  normal_message ""
  normal_message "\tThis script will scan recursively following folders:"
  normal_message "\t- for exaramel:  /tmp, /etc/init, /etc/init.d, /etc/systemd/system"
  normal_message "\t- for fobushell: your centreon folder"
  normal_message ""
  normal_message "\tFor more details about Yara you can check"
  normal_message "\t- the documentation: https://yara.readthedocs.io/en/stable/"
  normal_message "\t- the readme:        https://github.com/VirusTotal/yara/blob/master/README.md"
  normal_message "\t- yara help:         \$ yara -h"
  #Usage
  normal_message ""
  normal_message "Usage:"
  normal_message ""
  output_message "\tDo not run this script from the '/tmp' or your 'centreon' folder to avoid false positives (ie: the rules)"
  normal_message ""
  success_message "\t-r\tRun the script"
  normal_message "\t-h\tDisplay this help"
  #Requirement and Help
  normal_message ""
  normal_message "Requirement:"
  normal_message ""
  normal_message "\tMake sure to have installed the yara software\n"
  info_message "\tOn CentOS 7:"
  normal_message "\t\tyum install epel-release"
  normal_message "\t\tyum clean all"
  normal_message "\t\tyum install yara.x86_64\n"
  info_message "\tOn CentOS 6:"
  normal_message "\t\tUse the tool provided on the Forensic repository"
  normal_message "\t\tyum install https://forensics.cert.org/centos/cert/6/x86_64/yara-3.5.0-7.1.el6.x86_64.rpm"
  normal_message ""
}

#---
## {Variables}
#---
RUN=0
YARA=""
RULES_FOLDER="CERTFR-2021-IOC-002-YARA_2021-02-16"
CENTREON_ETC_FILE="/etc/centreon/centreon.conf.php"
CENTREON_PATH=""
EXARAMEL_PATH_TO_CHECK=("/tmp/" "/etc/init/" "/etc/init.d/" "/etc/systemd/system/")
COUNT=0

#---
## {Check if mandatory Yara tool is installed}
#---
function check_that_yara_is_installed() {
  # searching for the binary path
  YARA=$(which yara)
  if [[ -z $YARA ]]; then
    usage
    error_message "Yara binary was not found\n"
    exit 1
  else
    info_message "Yara binary found in: $YARA\n"
  fi
  # Checking the binary response
  if ! [[ -x "$(command -v $YARA)" ]]; then
    usage
    error_message "Yara binary was not found\n"
    exit 1
  fi
}

#---
## {Search for Centreon configuration file 'centreon.conf.php'}
#---
function find_centreon_configuration_file() {
  normal_message "Searching for Centreon configuration file in default folders"
  # Searching configuration file in default folder
  GET_CENTREON_ETC=$(ls "$CENTREON_ETC_FILE" 2>/dev/null)
  if [[ ${#GET_CENTREON_ETC[@]} -eq 1 && -n ${GET_CENTREON_ETC[0]} && -e ${GET_CENTREON_ETC[0]} ]]; then
    CENTREON_ETC_FILE=${GET_CENTREON_ETC[0]}
    info_message "Found file: $GET_CENTREON_ETC\n"
  else
    error_message "Centreon configuration file was not found in folders commonly used\n"
    # Searching configuration file on all the platform
    normal_message "Searching for Centreon configuration file in all the filesystem"
    FOUND_ETC_FOLDER=$(find / -name "centreon.conf.php" 2>/dev/null)
    if [[ ${#FOUND_ETC_FOLDER[@]} -eq 1 && -n ${FOUND_ETC_FOLDER[0]} && -e ${FOUND_ETC_FOLDER[0]} ]]; then
      CENTREON_ETC_FILE=${FOUND_ETC_FOLDER[0]}
      success_message "Found file: $CENTREON_ETC_FILE\n"
    else
      # Reseting provided configuration file and ask later for centreon installation folder
      CENTREON_ETC_FILE=""
      error_message "Centreon configuration file was not found in the filesystem\n"
    fi
  fi
}

#---
## {Search for Centreon web installation path from the configuration file}
#---
function find_centreon_path() {
  normal_message "Searching for installed Centreon path"
  #Find centreon path in the configuration file
  if [[ -n $CENTREON_ETC_FILE ]]; then
    while IFS= read -r LINE; do
      if [[ "$LINE" == *"centreon_path"* ]]; then
        VALUE=$(echo $LINE | cut -d '=' -f 2)
        VALUE=$(echo $VALUE | tr -d "'")
        CENTREON_PATH=$(echo $VALUE | tr -d ";")
      fi
    done <"$CENTREON_ETC_FILE"
  else
    error_message "Skipping Centreon configuration file parsing\n"
    ask_for_centreon_configuration_location
  fi

  # Check that the path exists and is a folder
  if [[ -n $CENTREON_PATH && -d $CENTREON_PATH ]]; then
    info_message "Setting Centreon path as: $CENTREON_PATH\n"
  else
    error_message "Cannot find Centreon path in the configuration file\n"
    ask_for_centreon_configuration_location
  fi
}

#---
## {Execute the ANSSI rules}
#---
function run_rule() {
  local RULE=$1
  local PATH=$2
  normal_message "Testing rule: $RULE on $PATH"
  #Check that the folder exists and we can read it
  if [[ -d $PATH && -r $PATH ]]; then
    RESULT=$("$YARA" --recursive "$RULE" "$PATH")
    if [[ -z $RESULT ]]; then
      success_message "Yara found nothing using the rule $RULE on the files of $PATH"
    else
      output_message "Yara tool returned the message:"
      error_message "$RESULT"
      normal_message ""
      ((COUNT += 1))
    fi
  else
    error_message "\tFolder: $PATH does not exists or is not readable by this user"
    normal_message "\tSkipping this folder\n"
  fi
}

#---
## {Find provided ANSSI rules}
#---
function find_rules() {
  info_message "Searching rules provided by the ANSSI"
  cd "$RULES_FOLDER"
  RULES=$(ls)
  for RULE in ${RULES[@]}; do
    if [[ $RULE == "exaramel.yara" ]]; then
      for PATH in ${EXARAMEL_PATH_TO_CHECK[@]}; do
        run_rule "$RULE" "$PATH"
      done
    else
      run_rule "$RULE" "$CENTREON_PATH"
    fi
  done
  cd ..

  if [[ $COUNT -gt 0 ]]; then
    WORDING="issues were"
    if [[ $COUNT -eq 1 ]]; then
      WORDING="issue was"
    fi
    error_message "\n\t$COUNT $WORDING found\n"
    error_message "\tYour platform may have been compromised."
    error_message "\tApply as soon as possible your incidence response plan"
    normal_message ""
  fi
}

#---
## {Ask for Centreon location}
#----
function ask_for_centreon_configuration_location() {
  local ERROR=1
  while [ $ERROR -ne 0 ]; do
    output_message "Please specify in which folder Centreon is installed:"
    normal_message "\n> "
    read CUSTOM_LOCATION

    if [[ -z $CUSTOM_LOCATION ]]; then
      error_message "\nEmpty path given\n"
    elif [[ -n $CUSTOM_LOCATION && -d $CUSTOM_LOCATION ]]; then
      ERROR=0
      CENTREON_PATH=$CUSTOM_LOCATION
    else
      error_message "\nFolder: '$CUSTOM_LOCATION' not found, not a directory or not readable\n"
    fi
  done
}

#---
## {Process options}
#----
while getopts "rh" OPTIONS; do
  case ${OPTIONS} in
  r)
    # Run the script
    RUN=1
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

if [[ $RUN -eq 1 ]]; then
  check_that_yara_is_installed
  find_centreon_configuration_file
  find_centreon_path
  find_rules
else
  usage
  exit 1
fi
