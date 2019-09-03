#!/bin/bash

# Script to backup and deploy PR files modification.
# Currently working on the open-source solution.
# Won't work without adaptation on the widgets or modules

# Licensed under the Apache License, Version 2.0 (the "License");
# author:sc979
# https://github.com/sc979

if [ $# -ne 2 ]
then
	echo
	echo "Two arguments are needed and you given : $# "
	echo "1 - The name of the file listing the modified files (i.e. fileLocation.txt)"
	echo "2 - The Sha1 of the PR to fetch in"
	echo "e.g. : deployPR.sh fileLocation.txt 0123456789012345678901234567890123456789"
	echo
	exit 1
fi

# getting the modified file list
# Checking file list to apply
if [ ! -e $1 ]
then
	echo
	echo "Error : The file isn't available in the current folder"
	echo
	exit 1
elif [ ! -r $1 ]
then
	echo
	echo "Error : We can't read the file. Please check the given rights."
	echo
	exit 1
elif [ ! -s $1 ]
then
	echo
 	echo "Error : The file is empty"
	echo
 	exit 1
fi

# getting the sha1 of the raw files
SHA1_LENGTH=`expr length $2`
if [ $SHA1_LENGTH -ne 40 ]
then
	echo "Error : The SHA1 is "$SHA1_LENGTH" characters long. Please insert 40 characters."
	exit 1
fi

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

# getting the Centreon's path
CENTREON_PATH=`cat /etc/centreon/centreon.conf.php | grep centreon_path | cut -d "'" -f2`
if [ -z $CENTREON_PATH ]
then
	# Asking for the right path, as we couldn't find the conf file
	echo
	echo "Error : We can't find your Centreon's path !"
	echo "- What is your Centreon's path ?"
	read CENTREON_PATH
fi

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

GITHUB_LOCATION="https://raw.githubusercontent.com/centreon/centreon/$2"

#echo "DEBUG -> github = '$GITHUB_LOCATION'"
echo

FILE_COUNT=0
FILE_ERROR=0
NEW_FILES=0
NEW_FOLDERS=0
DELETED_FILES=0


# Backup and deploy
for i in `cat $1`
do
	FILE_PATH=`dirname "$i"`
	FILE_NAME=`basename "$i"`
	OLD_FILE="$CENTREON_PATH$i"
	FILE_COUNT=$((FILE_COUNT+1))

	echo "Applying modifications - "$FILE_COUNT" to : "$i

	#echo "DEBUG -> old file = "$OLD_FILE

	wget --quiet $GITHUB_LOCATION"/"$FILE_PATH"/"$FILE_NAME
	# checking return code of wget
	WGET_RETURN=$?
	if [ $WGET_RETURN -eq 0 ]
	then
		#echo "DEBUG -> wget OK"
		# giving rights and ownership
		chmod 775 $FILE_NAME
		chown centreon. $FILE_NAME

		# as we don't know if the modified file have been deleted or not in the PR
		# we need to check if it has been downloaded from the wget command
		
		#echo "DEBUG -> begin the checks"
		#echo "DEBUG -> file : "$FILE_NAME
		
		if [ -f "${FILE_NAME}" ]
		then
			#echo "DEBUG -> new file have been downloaded"
			# checking that the file to modify already exist

			#echo "DEBUG -> old_file : "$OLD_FILE

			if [ ! -f "${OLD_FILE}" ]
			then
				NEW_FILES=$((NEW_FILES+1))
				#echo "DEBUG -> the old file don't exist"

				# checking if the destination directory exist

				#echo "DEBUG -> folder to check : "$CENTREON_PATH$FILE_PATH

				if [ ! -d "$CENTREON_PATH$FILE_PATH" ]
				then 
					#echo "DEBUG -> destination folder don't exist"
					#echo "DEBUG -> creating the folder"
					mkdir -p $CENTREON_PATH$FILE_PATH
					NEW_FOLDERS=$((NEW_FOLDERS+1))

				fi
			fi

			#echo "DEBUG -> moving the new file to the destination"
			#echo "DEBUG -> destination : "$FILE_NAME $CENTREON_PATH$FILE_PATH
			mv -f $FILE_NAME $CENTREON_PATH$FILE_PATH
			
		else
			# as we couldn't download the file, it means that it has been deleted in the PR
			# we don't delete it, but rename the old file to be able to restore it if needed
			
			#echo "DEBUG -> the new file don't exist"
			#echo "DEBUG -> deleting the old file"
			#echo "DEBUG -> old_file location : "$CENTREON_PATH$i
			cp -f $CENTREON_PATH$i{,.toDelete}
			rm -f $CENTREON_PATH$i
			DELETED_FILES=$((DELETED_FILES+1))
		fi
	else
		echo "Error : wget was unable to get the file - return code : "$WGET_RETURN
		echo
		FILE_ERROR=$((FILE_ERROR+1))
	fi
done

echo
echo "Files modified = "$FILE_COUNT
echo "Files created = "$NEW_FILES
echo "Files deleted = "$DELETED_FILES
echo "Folder created = "$NEW_FOLDERS

if [ $FILE_ERROR -gt 0 ]
then
	echo "An error occured, please check the '"$FILE_ERROR"' printed lines"
fi

echo
echo "Please manually apply any upgrade script found in "$CENTREON_PATH"/www/install/"
echo