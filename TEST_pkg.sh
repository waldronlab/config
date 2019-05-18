#!/bin/bash

pkg=$1

for name in devel release oldrel
do
    r_loc=$HOME/src/svn/r-$name/R/bin/R/
    lib_dir=$HOME/src/lib/r-$name
    if [ ! -d $lib_dir ]; then
        mkdir -p $lib_dir
    fi
    echo "Testing $pkg on r-${name}..."
    R_LIBS_USER=$lib_dir $r_loc --vanilla CMD build $pkg
    echo "Checking $pkg on r-${name}"
    R_LIBS_USER=$lib_dir $r_loc --vanilla CMD check ${pkg}_*.tar.gz
done



