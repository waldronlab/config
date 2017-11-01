#!/bin/bash
# Input 1 = config file name 
#   - Any of the given repository config files (e.g., bashrc)

# It will NOT overwrite any existing files

cp -vn ${1} ~/.${1}

