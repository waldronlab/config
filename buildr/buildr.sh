#!/bin/bash
set -euo pipefail

# version must be the R-X-Y-branch version number e.g, '4-1' or 'devel'
version=$1
# revision is the svn checkout revision number e.g., 12345
revision=${2:-}

if [ -z "${version// }" ] || [ "$version" = "release" ] ||
    [ "$version" = "oldrel" ]; then
    echo "Enter numeric version, e.g., '4-1', '4-2', or 'devel'"
    exit 1
fi

if [ -n "${revision// }" ]; then
    echo "revision is set to ${revision}"
    ending="/@${revision}"
else
    ending="/"
fi

echo "Checking for dependencies (svn ccache) ..."
deps=0
for name in svn ccache
do
    [[ $(which $name 2>/dev/null) ]] || \
        { echo -e "\n$name needs to be installed. See 'setup.sh'"; deps=1; }
done
[[ $deps -ne 1 ]] && echo "OK" || \
    { echo -e "\nInstall dependencies and rerun this script\n"; exit 1; }

baseurl='https://svn.r-project.org/R/'
if [ "$version" = "devel" ]; then
    vers_folder="trunk${ending}"
else
    vers_folder="branches/R-${version}-branch${ending}"
fi

FULLURL=$baseurl$vers_folder
RFOLDER="r-$version"
INSTALL_DIR=$HOME/src/svn
RINST=$INSTALL_DIR/$RFOLDER
RSOURCE=$RINST/source   # svn checkout and build
RPREFIX=$RINST/inst     # clean install target

mkdir -p "$RSOURCE"
cd "$RSOURCE"

echo -e "Getting R version from:\n  $FULLURL\nto:\n  $RSOURCE"
echo -e "Will install to:\n  $RPREFIX"

svn co "$FULLURL" .
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
    --prefix="${RPREFIX}"           \
    --enable-R-shlib 		    \
    --with-blas="-lblas"	   \
    --with-lapack="-llapack"   \
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

make -j$(nproc) && make install

echo ""
echo "*** Done ***"
echo "R installed to: ${RPREFIX}"
echo "Run with:       ${RPREFIX}/bin/R"
