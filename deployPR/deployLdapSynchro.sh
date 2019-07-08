#!/bin/bash

# Script to backup and deploy PR files modification.
# Currently working on the open-source solution.
# Won't work without adaptation on the widgets or modules

# Licensed under the Apache License, Version 2.0 (the "License");
# author:sc979
# https://github.com/sc979


# Asking for readiness ;)
MARK=0;
while [ $MARK ]
do
	echo
	echo "- Did you backup your Centreon's databases ?"
	read -r -p "[y/N] " REPLY
	if [[ "$REPLY" =~ ^([yY][eE][sS]|[yY])+$ ]]
	then
		MARK=1
		break
	else
		echo "NO ? -> Please do so before launching this script."
		exit 1;
	fi
done

# getting the sha1 of the raw files
MARK=0;
while [ $MARK ]
do
	echo
	echo "- What is the sha1 of the raw files of the pull request ?"
	read REPLY_SHA1
	if [ ! -z $REPLY_SHA1 ]
	then
		SHA1_LENGTH=`expr length $REPLY_SHA1`
		if [ $SHA1_LENGTH -eq 40 ]
		then
			MARK=1;
			break;
		else
			echo "You inserted : "$SHA1_LENGTH" characters. Please insert exactely 40 characters."
		fi
	else
		echo "Could you retry. The sha1 of the commit should be exactely 40 characters."
	fi
done

# getting the Centreon's path
CENTREON_PATH=`cat /etc/centreon/centreon.conf.php | grep centreon_path | cut -d "'" -f2`
if [ ! -z $CENTREON_PATH ]
then
	MARK=0;
	while [ $MARK ]
	do
		echo
		echo "- Is the Centreon's path correct ?"
		echo $CENTREON_PATH

		read -r -p "[y/N] " REPLY
		if [[ "$REPLY" =~ ^([yY][eE][sS]|[yY])+$ ]]
		then
			MARK=1
			break
		else
			echo "NO ? -> Please give us the correct path ? :"
			read CENTREON_PATH
		fi
    done
fi

GITHUB_LOCATION="https://raw.githubusercontent.com/centreon/centreon/$REPLY_SHA1"

echo $GITHUB_LOCATION


# getting the modified file list
MARK=0;
FILE_LIST="filesLocations.txt"
while [ $MARK ]
do
	echo
	echo "- Is the modified files list named '$FILE_LIST' ?"
	read -r -p "[y/N] " REPLY
	if [[ "$REPLY" =~ ^([yY][eE][sS]|[yY])+$ ]]
	then
		MARK=1
		break
	else
		echo "NO ? -> Please give us the list filename ? :"
		read FILE_LIST
	fi
done

# Checking file list to apply
if [ ! -e "${FILE_LIST}" ]
then
	echo "Error : The '$FILE_LIST' isn't available in the current folder"
	echo
	exit 1
fi

if [ ! -r "${FILE_LIST}" ]
then
	echo "Error : We can't read the file. Please check the given rights of '$FILE_LIST'."
	echo
	exit 1
fi

if [ ! -s "${FILE_LIST}" ]
then
 	echo "Error : The file '$FILE_LIST' is empty"
	echo
 	exit 1
fi

# Backup and deploy
for i in `cat "$FILE_LIST"`
do
	echo
	echo "Backup, download and update file : "$i
	yes | cp $CENTREON_PATH$i{,.old}

	FILE_PATH=`dirname "$i"`
	FILE_NAME=`basename "$i"`

	wget --quiet $GITHUB_LOCATION"/"$FILE_PATH"/"$FILE_NAME
	yes | mv $FILE_NAME $CENTREON_PATH$FILE_PATH
	echo
done

#echo "An error occured, please check the printed lines"
echo "All files have been backuped and modified"

echo
echo "Please manually apply the upgrade script if needed"