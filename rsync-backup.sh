#!/bin/bash

rsync -aP --exclude-from=$HOME/gh/config/ignorelist.txt $HOME /media/mr148/Seagate\ Expansion\ Drive/LinuxBackup/home/

