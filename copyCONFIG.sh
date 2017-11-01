#!/bin/bash
# Input 1 = config file name 
#   - Any of the given repository config files (e.g., bashrc)

# It will NOT overwrite any existing files

if [[ ${1} == "README.md" || ${1} == "copyCONFIG.sh" ]]; then
    echo "Nothing to do with ${1}"
elif [[ ${1} == "ssh-slash-config" ]]; then
    cp -vn ./${1} $HOME/.ssh/config
else
    cp -vn ./${1} $HOME/.${1}
fi
