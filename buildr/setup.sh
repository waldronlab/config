#!/bin/bash
set -euo pipefail

## see also
## https://github.com/Jiefei-Wang/Painless-R-compilation-and-installation-on-Ubuntu
## macOS setup follows the Bioconductor Build System (BBS) guide:
## https://github.com/Bioconductor/BBS/blob/devel/Doc/Prepare-macOS-Big-Sur-HOWTO.md
## and https://mac.r-project.org/tools/

if [ "$(uname -s)" != "Darwin" ]; then
    ## install dependencies
    apt-get build-dep r-base r-base-core
    apt-get install
    apt-get install make subversion ccache build-essential libreadline-dev \
    gfortran xorg-dev libbz2-dev liblzma-dev libpcre2-dev \
    libcurl4 libcurl4-openssl-dev libblas-dev libtirpc-dev
    exit 0
fi

ARCH=$(uname -m)                          # arm64 or x86_64
DARWIN_MAJOR=$(uname -r | cut -d. -f1)
DOWNLOADS=$HOME/Downloads
mkdir -p "$DOWNLOADS"

XQUARTZ_VERSION=2.8.5
GFORTRAN_URL=https://github.com/R-macos/gcc-14-branch/releases/download/gcc-14.2-darwin-r2.1/gfortran-14.2-darwin20-r2-universal.tar.xz
LIBS_URL=https://mac.r-project.org/bin

## Libraries needed to build R (r-base-dev bundle: xz, pcre2, cairo, jpeg,
## libpng, tiff, openssl, texinfo, libdeflate, zstd) plus readline, pango,
## pkg-config, and subversion
R_LIBS="r-base-dev readline5 pango pkgconfig subversion"
## Libraries BBS installs for CRAN/Bioconductor packages
## (BBS/mac-files/required_cran.txt)
BBS_LIBS="fftw fribidi gsl glpk hdf5 harfbuzz netcdf openssl pkgconfig pcre2
proj protobuf udunits xz"

## Install Apple's Command Line Tools (BBS 2.6)
if ! xcode-select -p >/dev/null 2>&1; then
    echo "Installing Xcode command line tools; rerun this script when done"
    xcode-select --install
    exit 1
fi
echo "Command Line Tools: $(xcode-select -p)"

## Install XQuartz (BBS 2.4)
if [ ! -d /opt/X11 ]; then
    echo "Installing XQuartz ${XQUARTZ_VERSION} ..."
    pkg="XQuartz-${XQUARTZ_VERSION}.pkg"
    curl -L -o "$DOWNLOADS/$pkg" \
        "https://github.com/XQuartz/XQuartz/releases/download/XQuartz-${XQUARTZ_VERSION}/${pkg}"
    sudo installer -pkg "$DOWNLOADS/$pkg" -target /
    sudo mkdir -p /usr/local/include
    sudo ln -sfn /opt/X11/include/X11 /usr/local/include/X11
    echo "Log out and back in so the XQuartz PATH changes take effect"
else
    echo "XQuartz: found in /opt/X11"
fi

## Install gfortran (BBS 2.8)
if [ ! -x /opt/gfortran/bin/gfortran ]; then
    echo "Installing gfortran from ${GFORTRAN_URL} ..."
    tarball="$DOWNLOADS/$(basename "$GFORTRAN_URL")"
    curl -L -o "$tarball" "$GFORTRAN_URL"
    sudo tar -xf "$tarball" -C /
fi
## point /opt/gfortran/SDK at the installed SDK
sudo ln -sfn "$(xcrun --show-sdk-path)" /opt/gfortran/SDK
echo "gfortran: $(/opt/gfortran/bin/gfortran --version | head -1)"

## Install Simon's binaries into /opt/R/<arch> (BBS 2.9)
## Shell version of install.libs() from https://mac.r-project.org/bin/install.R
## so no existing R installation is needed.
repo=$(curl -fsSL "$LIBS_URL/REPOS" | grep "/${ARCH}\$" |
    awk -F/ -v max="$DARWIN_MAJOR" \
        '{ v = $1; gsub(/[^0-9]/, "", v); if (v + 0 <= max) print v, $0 }' |
    sort -n | tail -1 | cut -d' ' -f2)
if [ -z "$repo" ]; then
    echo "No binaries at $LIBS_URL for ${ARCH} darwin${DARWIN_MAJOR}"
    exit 1
fi
echo "Using library binaries from $LIBS_URL/$repo"

## resolve dependencies (BuiltWith) and list the binary tarballs to install
binaries=$(curl -fsSL "$LIBS_URL/$repo/PACKAGES" | awk -v want="$(echo $R_LIBS $BBS_LIBS)" '
    BEGIN { RS = ""; FS = "\n" }
    {
        pkg = ver = bundle = bw = bin = ""
        for (i = 1; i <= NF; i++) {
            split($i, kv, ": ")
            if (kv[1] == "Package") pkg = kv[2]
            else if (kv[1] == "Version") ver = kv[2]
            else if (kv[1] == "Bundle") bundle = kv[2]
            else if (kv[1] == "BuiltWith") bw = kv[2]
            else if (kv[1] == "Binary") bin = kv[2]
        }
        key = (bundle != "") ? bundle : pkg "-" ver
        known[key] = 1; builtwith[key] = bw; binary[key] = bin
        if (pkg != "") name2key[pkg] = key
        if (bundle != "") name2key[bundle] = key
    }
    function add(k,    d, m, j) {
        if (k in seen) return
        seen[k] = 1
        if (!(k in known)) { print "missing: " k > "/dev/stderr"; bad = 1; return }
        m = split(builtwith[k], d, /[, ]+/)
        for (j = 1; j <= m; j++) if (d[j] != "") add(d[j])
        if (binary[k] != "") print binary[k]
    }
    END {
        n = split(want, w, /[ \n]+/)
        for (i = 1; i <= n; i++) if (w[i] != "")
            add((w[i] in name2key) ? name2key[w[i]] : w[i])
        exit bad
    }')

sudo mkdir -p "/opt/R/${ARCH}"
for bin in $binaries; do
    echo "Downloading + installing $bin ..."
    curl -fsSL "$LIBS_URL/$repo/$bin" | sudo tar fxj - -C /
done

## ccache is not among Simon's binaries; it is only a compiler wrapper (not a
## linked library) so Homebrew is fine for it
if ! command -v ccache >/dev/null 2>&1; then
    if command -v brew >/dev/null 2>&1; then
        brew install ccache
    else
        echo "Optional: install ccache (e.g., 'brew install ccache')"
    fi
fi

## Tcl/Tk (optional, for the tcltk package) ships with the CRAN R installer
if [ ! -f "/opt/R/${ARCH}/lib/tclConfig.sh" ]; then
    echo ""
    echo "Optional: for Tcl/Tk support, install only Tcl/Tk from a CRAN R"
    echo "installer (.pkg) via 'Customize' at https://mac.r-project.org/"
fi

echo ""
echo "Add to your shell profile:"
echo "  export PATH=\"/opt/gfortran/bin:/opt/R/${ARCH}/bin:\$PATH\""
