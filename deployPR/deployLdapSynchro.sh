#!/bin/bash

# script to apply specificly PR7627 modifications

# Licensed under the Apache License, Version 2.0 (the "License");
# author:sc979
# https://github.com/sc979

centreonPath="/usr/share/centreon"

githubLocation="https://raw.githubusercontent.com/centreon/centreon/544d21751e37e80ff3220869d7abc94dc8653d43"

for i in `cat filesLocations.txt`
do
	echo "backup file : "$i
	cp $centreonPath"/"$i{,.old}

	filePath=`dirname "$i"`
	fileName=`basename "$i"`

	echo "downloading : "
	wget $githubLocation"/"$filePath"/"$fileName
	mv $filename $centreonPath"/"$filePath
	echo
done
echo "all files modified"i
echo
echo "please manually apply the upgrade script"
