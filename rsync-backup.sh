#!/bin/bash

rsync -aP --exclude-from=ignorelist.txt $HOME /media/$USER/ /media/mr148/Seagate\ Expansion\ Drive/Sys76Backup

