#!/bin/bash

# Script to stash and update every Centreon's repos

# Licensed under the Apache License, Version 2.0 (the "License");
# author:sc979
# https://github.com/sc979

error=0;
REPLY=( $(ls | grep -i 'centreon') )
for i in ${REPLY[@]}; do
	echo ""
	echo "Repo to update : "$i
	cd $i
	git fetch
	git stash clear && git stash
        git checkout master
        git pull
	git stash apply
#	if [ $? -ne 0]; then
#		echo "FAILED";
#		$error=1;
#	fi;
	cd ..
	echo "OK"
done
echo ""
echo "All done"
