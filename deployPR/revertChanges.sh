#!/bin/bash

# Script to revert PR's modifications

# Licensed under the Apache License, Version 2.0 (the "License");
# author:sc979
# https://github.com/sc979

centreonPath="/usr/share/centreon"

for i in `cat filesLocations.txt`
do
	echo "restoring file : "$i
	yes | cp $centreonPath"/"$i{.old,}
	yes | rm $centreonPath"/"$i".old"
	echo
done
echo "all files processed"
echo
echo "please restore manually your DB dump"
