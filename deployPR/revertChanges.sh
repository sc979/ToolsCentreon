#!/bin/bash

# script to revert PR's modifications

# Licensed under the Apache License, Version 2.0 (the "License");
# author:sc979
# https://github.com/sc979

centreonPath="/usr/share/centreon"

for i in `cat filesLocations.txt`
do
	echo "restoring file : "$i
	cp $centreonPath"/"$i{.old,}
	rm $centreonPath"/"$i".old"
	echo
done
echo "all file processed"
echo
echo "please restore your DB dump"
