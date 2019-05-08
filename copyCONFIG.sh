#!/bin/bash
# Input 1 = config file name
#   - Any of the given repository config files (e.g., bashrc)

# It will NOT overwrite any existing files

if [[ ${1} == "README.md" || ${1} == "copyCONFIG.sh" ]]; then
    echo "Nothing to do with ${1}"
elif [[ ${1} == "ssh-slash-config" ]]; then
    cp -vn ./${1} $HOME/.ssh/config
elif [[ ${1} == "version_bump.sh" ]]; then
    mkdir -p $HOME/src
    cp -vn ./${1} $HOME/src
    if [ ! -f $HOME/.bash_aliases ]; then
        touch $HOME/.bash_aliases
    fi
    echo 'alias bump="$HOME/src/version_bump.sh"' >> $HOME/.bash_aliases
elif [[ ${1} == "buildr.sh" ]]; then
    mkdir -p $HOME/src/svn
    cp -vn ./buildr/${1} $HOME/src/svn/
else
    cp -vn ./${1} $HOME/.${1}
fi
