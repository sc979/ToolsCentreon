#!/bin/bash

# Script to launch as many acceptance tests as you give their name as argument.

# Licensed under the Apache License, Version 2.0 (the "License");
# author:sc979
# https://github.com/sc979

for word in $*; do sudo php ../centreon-build/script/acceptance.php -d centos7 -v 19.04 features/"$word"; done
