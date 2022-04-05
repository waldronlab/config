#!/bin/bash

# version must be the R-X-Y-branch version number e.g, '4-1' or 'devel'
version=$1

if [ -z "${version// }" ] || [ $version = "release" ] &&
    [ $version = "oldrel" ]; then
    echo "Enter numeric version, e.g., '4-1', '4-2', or 'devel'"
    exit 1
fi

echo "Checking for dependencies (svn ccache) ..."
for name in svn ccache
do
    [[ $(which $name 2>/dev/null) ]] || \
        { echo -en "\n$name needs to be installed. See 'setup.sh'"; deps=1; }
done

[[ $deps -ne 1 ]] && echo "OK" || \
    { echo -en "\nInstall dependencies and rerun this script\n"; exit 1; }

baseurl='https://svn.r-project.org/R/'

if [[ $version = "devel" ]]; then
    vers_folder='trunk/'
else
    vers_folder="branches/R-${version}-branch/"
fi

FULLURL=$baseurl$vers_folder

RFOLDER="r-$version/R"

INSTALL_DIR=$HOME/src/svn

RINST=$INSTALL_DIR/$RFOLDER

for dir in $INSTALL_DIR $RINST
do
    if [ ! -d $dir ]; then
        mkdir -p $dir
    fi
done

cd $INSTALL_DIR

echo -e "Getting R version from:\n $FULLURL to \n $RINST"
svn co $FULLURL $RINST

cd $RINST

./tools/rsync-recommended

R_PAPERSIZE=letter				\
R_BATCHSAVE="--no-save --no-restore"    \
R_BROWSER=xdg-open				\
PAGER=/usr/bin/pager		    \
PERL=/usr/bin/perl				\
R_UNZIPCMD=/usr/bin/unzip	    \
R_ZIPCMD=/usr/bin/zip		    \
R_PRINTCMD=/usr/bin/lpr		    \
LIBnn=lib					    \
AWK=/usr/bin/awk                \
CC="ccache gcc"					\
CFLAGS="-ggdb -pipe -std=gnu99 -Wall -pedantic" \
CXX="ccache g++"				\
CXXFLAGS="-ggdb -pipe -Wall -pedantic"  \
FC="ccache gfortran"	 	    \
F77="ccache gfortran"		    \
./configure 					\
    --prefix=${RINST}           \
    --enable-R-shlib 		    \
    --with-blas				    \
    --with-lapack				\
    --with-readline 		    \
    --with-tcltk                \
    --with-cairo=yes
#    --with-darwinssl            \ # MAC only
#    --without-x                 \
#    --with-libpng               \
#    --with-libtiff              \
#    --with-jpeglib              \
#    --enable-memory-profiling

#CC="clang -O3"                 \
#CXX="clang++ -03"				\
#make svnonly

make

cd $RINST

make install

echo "*** Done ***"
