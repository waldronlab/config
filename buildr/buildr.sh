#!/bin/bash

echo "Checking for dependencies (svn ccache) ..."
for name in svn ccache
do
    [[ $(which $name 2>/dev/null) ]] || \
        { echo -en "\n$name needs to be installed. See 'setup.sh'"; deps=1; }
done

[[ $deps -ne 1 ]] && echo "OK" || \
    { echo -en "\nInstall dependencies and rerun this script\n"; exit 1; }

version=$1

if [ -z "${version// }" ] || [ $version != "release" -a $version != "devel" ]; then
    echo "Enter either 'devel' or 'release' version"
    exit 1
fi

baseurl='https://svn.r-project.org/R/'

vers_folder='branches/R-3-6-branch/' && [[ $version = "devel" ]] && vers_folder='trunk/'

fullurl=$baseurl$vers_folder

rfolder="r-$version/R"

INSTALL_DIR=$HOME/src/svn

if [ ! -d $RSOURCES ]; then
    mkdir -p $RSOURCES
fi

cd $RSOURCES

svn co $fullurl $rfolder

RINST=$HOME/src/svn/$rfolder

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
MAKE="make -j8"					\
./configure 					\
    --prefix=${RINST}           \
    --enable-R-shlib 		    \
	--with-blas				    \
	--with-lapack				\
    --with-readline 		    \
    --with-cairo=yes

#CC="clang -O3"                 \
#CXX="clang++ -03"				\
#make svnonly

make

echo "*** Done -- now run 'make install' in $RINST"

cd $RINST

make install
