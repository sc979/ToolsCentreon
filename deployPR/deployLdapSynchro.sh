#!/bin/bash

# Script to apply specifically PR7627 modifications

# Licensed under the Apache License, Version 2.0 (the "License");
# author:sc979
# https://github.com/sc979

centreonPath="/usr/share/centreon"

githubLocation="https://raw.githubusercontent.com/centreon/centreon/06a5d44f0f1393ea63e4964723735c47c4fd2f7d"

for i in `cat filesLocations.txt`
do
	echo "backup file : "$i
	yes | cp $centreonPath"/"$i{,.old}

	filePath=`dirname "$i"`
	fileName=`basename "$i"`

	echo "downloading : "
	wget $githubLocation"/"$filePath"/"$fileName
	yes | mv $fileName $centreonPath"/"$filePath
	echo
done
echo "all files modified"
echo
echo "please manually apply the upgrade script"
