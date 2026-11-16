#!/bin/bash
set -euo pipefail

# version must be the R-X-Y-branch version number e.g, '4-1' or 'devel'
version=${1:-}
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

OS=$(uname -s)

# On macOS, use the toolchain from the Bioconductor build machines (BBS) and
# CRAN: CRAN gfortran in /opt/gfortran and Simon's library binaries in
# /opt/R/<arch> (https://mac.r-project.org/bin). Run 'setup.sh' first.
if [ "$OS" = "Darwin" ]; then
    ARCH=$(uname -m)
    OPTR=/opt/R/$ARCH
    export PATH="/opt/gfortran/bin:$OPTR/bin:$PATH"
    deplist="svn gfortran pkg-config"
else
    deplist="svn ccache"
fi

echo "Checking for dependencies ($deplist) ..."
deps=0
for name in $deplist
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

configure_args=(
    --prefix="${RPREFIX}"
    --enable-R-shlib
    --with-readline
    --with-cairo=yes
)

if [ "$OS" = "Darwin" ]; then
    NCPU=$(sysctl -n hw.ncpu)

    # ccache is optional on macOS
    if command -v ccache >/dev/null 2>&1; then
        cc_prefix="ccache "
    else
        cc_prefix=""
    fi

    # compiler flags from the CRAN nightly builds (mac.r-project.org logs);
    # macos_min matches the /opt/R/<arch> library binaries from 'setup.sh'
    # (darwin23/arm64 -> macOS 14 Sonoma; darwin20/x86_64 -> macOS 11 Big Sur)
    if [ "$ARCH" = "arm64" ]; then
        cflags="-falign-functions=64 -Wall -g -O2"
        macos_min="14.0"
    else
        cflags="-Wall -g -O2"
        macos_min="11.0"
    fi

    # Set the deployment target explicitly (as CRAN does). Otherwise CRAN's
    # gfortran derives it from the Darwin kernel version (e.g., Darwin 27 ->
    # '-mmacosx-version-min=18.0'), which Apple's assembler rejects
    export MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-$macos_min}"

    export R_PAPERSIZE=letter
    export R_BATCHSAVE="--no-save --no-restore"
    export R_BROWSER=open
    export PAGER=/usr/bin/less
    export PERL=/usr/bin/perl
    export R_UNZIPCMD=/usr/bin/unzip
    export R_ZIPCMD=/usr/bin/zip
    export R_PRINTCMD=/usr/bin/lpr
    export LIBnn=lib
    export AWK=/usr/bin/awk
    export CC="${cc_prefix}clang -arch ${ARCH}"
    export OBJC="${cc_prefix}clang -arch ${ARCH}"
    export CXX="${cc_prefix}clang++ -arch ${ARCH}"
    export CFLAGS="$cflags"
    export OBJCFLAGS="$cflags"
    export CXXFLAGS="$cflags"
    export FC="${cc_prefix}/opt/gfortran/bin/gfortran -arch ${ARCH}"
    export FFLAGS="-g -O2"
    export FCFLAGS="-g -O2"
    export CPPFLAGS="-I${OPTR}/include"
    export LDFLAGS="-L${OPTR}/lib"
    # LIBDIR (not PATH) so a Homebrew pkg-config can't pick up Homebrew libs
    export PKG_CONFIG_LIBDIR="${OPTR}/lib/pkgconfig:${OPTR}/share/pkgconfig"

    # like CRAN: R's internal BLAS (as a shared library) and LAPACK
    configure_args+=( --enable-BLAS-shlib --enable-memory-profiling )

    # X11 needs XQuartz (https://www.xquartz.org)
    if [ -d /opt/X11 ]; then
        configure_args+=( --with-x )
    else
        echo "XQuartz not found: building without X11"
        configure_args+=( --without-x )
    fi

    # Tcl/Tk from the CRAN R installer, installed in /opt/R/<arch>
    if [ -f "${OPTR}/lib/tclConfig.sh" ] && [ -f "${OPTR}/lib/tkConfig.sh" ]; then
        configure_args+=(
            --with-tcltk
            --with-tcl-config="${OPTR}/lib/tclConfig.sh"
            --with-tk-config="${OPTR}/lib/tkConfig.sh"
        )
    else
        echo "Tcl/Tk not found in ${OPTR}: building without Tcl/Tk"
        configure_args+=( --without-tcltk )
    fi
else
    NCPU=$(nproc)

    export R_PAPERSIZE=letter
    export R_BATCHSAVE="--no-save --no-restore"
    export R_BROWSER=xdg-open
    export PAGER=/usr/bin/pager
    export PERL=/usr/bin/perl
    export R_UNZIPCMD=/usr/bin/unzip
    export R_ZIPCMD=/usr/bin/zip
    export R_PRINTCMD=/usr/bin/lpr
    export LIBnn=lib
    export AWK=/usr/bin/awk
    export CC="ccache gcc"
    export CFLAGS="-ggdb -pipe -std=gnu99 -Wall -pedantic"
    export CXX="ccache g++"
    export CXXFLAGS="-ggdb -pipe -Wall -pedantic"
    export FC="ccache gfortran"
    export F77="ccache gfortran"

    configure_args+=(
        --with-blas="-lblas"
        --with-lapack="-llapack"
        --with-tcltk
    )
fi

# Other options:
#    --without-x
#    --with-libpng
#    --with-libtiff
#    --with-jpeglib
#    --enable-memory-profiling
#CC="clang -O3"
#CXX="clang++ -O3"
#make svnonly

./configure "${configure_args[@]}"

make -j"${NCPU}" && make install

echo ""
echo "*** Done ***"
echo "R installed to: ${RPREFIX}"
echo "Run with:       ${RPREFIX}/bin/R"
