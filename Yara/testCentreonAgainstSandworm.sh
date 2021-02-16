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

## {Format messages}
function success_message() {
  echo -e "\e[32m\e[1m"$1"\e[0m"
}
function error_message() {
  echo -e "\e[31m\e[1m$1\e[0m"
}
function output_message() {
  echo -e "\e[34m\e[1m$1\e[0m"
}
function info_message() {
  echo -e "\e[35m\e[1m$1\e[0m"
}
function normal_message() {
  echo -e "\e[0m$1"
}

## {Print description and usage}
function usage() {
  output_message "\nThis tool will use the Yara software and "
  output_message "test the rules provided by the ANSSI to test your platform against sandStorm"
  success_message "\nHelp:\n"
  normal_message "\tMake sure to have installed the yara software\n"
  output_message "\tOn CentOS 7 :"
  normal_message "\t\tyum install epel-release"
  normal_message "\t\tyum clean all"
  normal_message "\t\tyum install yara.x86_64\n"
  output_message "\tOn CentOS 6 :"
  normal_message "\t\tUse the Forensic repository available here :"
  normal_message "\t\thttps://centos.pkgs.org/6/forensics-x86_64/yara-3.5.0-7.1.el6.x86_64.rpm.html"
  normal_message "\t\tyum install yara-3.5.0-7.1.el6.x86_64.rpm\n"
}

## {Variables}
RULES_FOLDER="CERTFR-2021-IOC-002-YARA_2021-02-16"
CENTREON_ETC_FILE="/etc/centreon/centreon.conf.php"

## {Check if mandatory Yara is installed}
function check_that_yara_is_installed() {
  if ! [[ -x "$(command -v yara)" ]]; then
    error_message "Yara software was not found"
    usage
    exit 1
  fi
}

## {Search for Centreon configuration file 'centreon.conf.php'}
function find_centreon_configuration_file() {
  info_message "Search for Centreon configuration file"
  FOUND_ETC_FOLDER=$(find / -name "centreon.conf.php")
  if [[ ${#FOUND_ETC_FOLDER[*]} -ne 1 ]]; then
     error_message "More than one folder has been found"
     error_message "This feature will be implemented soon"
   else
     CENTREON_ETC_FILE=$FOUND_ETC_FOLDER
     success_message "Found file : $CENTREON_ETC_FILE"
   fi
}

## {Search for Centreon web installation path from configuration file}
function find_centreon_path() {
  info_message "Search for installed Centreon path"
  while IFS= read -r LINE; do
    if [[ "$LINE"  == *"centreon_path"* ]]; then
      VALUE=$(echo $LINE | cut -d '=' -f 2)
      VALUE=$(echo $VALUE | tr -d "'")
      VALUE=$(echo $VALUE | tr -d ";")
      success_message "Centreon path found = $VALUE"
    fi
  done < "$CENTREON_ETC_FILE"
}

## {Execute the ANSSI rules on Centreon web}
function run_rules() {
  RULES=$(find ./$RULES_FOLDER -name "*.yara")
  for i in ${RULES[@]}; do
    RULE_NAME=$(echo $i | cut -d '/' -f 3)
    info_message "Found rule : $i"
  done
}

## {Run the script}
check_that_yara_is_installed
find_centreon_configuration_file
find_centreon_path
run_rules

echo "END DEBUG"
exit 2;
