#!/bin/bash
# Create Ubuntu app-menu launchers for RStudio, one per R / Bioconductor setup
#
# Each launcher starts RStudio with
#   RSTUDIO_WHICH_R = $HOME/src/svn/<R build>/inst/bin/R
#   R_BIOC_LIB      = $HOME/R/<library>
#
# R_BIOC_LIB only takes effect if ~/.Renviron sets the library from it, e.g.
#   R_LIBS_USER=${R_BIOC_LIB-/home/<user>/R/bioc-release}
# (a plain R_LIBS_USER=... line in ~/.Renviron overrides the launcher).
#
# usage:
#   ./rstudio-launchers.sh           # create / refresh the launchers below
#   ./rstudio-launchers.sh --remove  # delete the launchers this script made
#
# Edit SETUPS when R or Bioconductor versions change, then re-run.
# Format: "<short name>:<R build in ~/src/svn>:<library in ~/R>"

SETUPS=(
    "Rel:r-4-6:bioc-release"
    "Dev:r-4-6:bioc-devel"
    "Old:r-4-5:bioc-oldrel"
)

# Setup used when opening .R/.Rproj files. Overrides
# /usr/share/applications/rstudio.desktop with a user copy that is hidden
# from the app menu (NoDisplay), so only the launchers above are shown.
# Set to "" to restore the system "RStudio" launcher.
DEFAULT="Dev"
SYSTEM_DESKTOP=/usr/share/applications/rstudio.desktop

RSTUDIO=/usr/lib/rstudio/rstudio
APPDIR=$HOME/.local/share/applications
PREFIX=rstudio-
MARKER="X-Generated-By=rstudio-launchers.sh"

set -euo pipefail
mkdir -p "$APPDIR"

# Remove launchers created by earlier runs so renamed setups don't linger
for f in "$APPDIR"/"$PREFIX"*.desktop "$APPDIR/rstudio.desktop"; do
    [[ -e $f ]] && grep -qx "$MARKER" "$f" && rm -v "$f"
done

if [[ ${1:-} == "--remove" ]]; then
    command -v update-desktop-database >/dev/null &&
        update-desktop-database "$APPDIR"
    exit 0
fi

[[ -x $RSTUDIO ]] || echo "Warning: RStudio not found at $RSTUDIO" >&2

for setup in "${SETUPS[@]}"; do
    IFS=: read -r name rbuild lib <<< "$setup"
    rbin=$HOME/src/svn/$rbuild/inst/bin/R
    libdir=$HOME/R/$lib
    file=$APPDIR/rstudio-$lib.desktop

    [[ -x $rbin ]] || echo "Warning: no R at $rbin" >&2
    [[ -d $libdir ]] || echo "Warning: no library at $libdir" >&2

    cat > "$file" <<EOF
[Desktop Entry]
Type=Application
Name=RStudio $name
Comment=RStudio with $rbuild and the ~/R/$lib library
Exec=env RSTUDIO_WHICH_R=$rbin R_BIOC_LIB=$libdir $RSTUDIO %F
Icon=rstudio
Terminal=false
Categories=Development;IDE;
$MARKER
EOF
    if command -v desktop-file-validate >/dev/null; then
        desktop-file-validate "$file"
    fi
    echo "Created $file"

    if [[ $name == "$DEFAULT" ]]; then
        if [[ -f $SYSTEM_DESKTOP ]]; then
            file=$APPDIR/rstudio.desktop
            sed "s|^Exec=$RSTUDIO|Exec=env RSTUDIO_WHICH_R=$rbin R_BIOC_LIB=$libdir $RSTUDIO|" \
                "$SYSTEM_DESKTOP" > "$file"
            echo "Comment=RStudio with $rbuild and the ~/R/$lib library" >> "$file"
            echo "NoDisplay=true" >> "$file"
            echo "$MARKER" >> "$file"
            if command -v desktop-file-validate >/dev/null; then
                desktop-file-validate "$file"
            fi
            echo "Created $file (hidden; opens .R/.Rproj files with $name)"
        else
            echo "Warning: $SYSTEM_DESKTOP not found; no default set" >&2
        fi
    fi
done

command -v update-desktop-database >/dev/null &&
    update-desktop-database "$APPDIR"

if [[ -f $HOME/.Renviron ]] &&
    grep -q '^R_LIBS_USER=' "$HOME/.Renviron" &&
    ! grep -q '^R_LIBS_USER=.*R_BIOC_LIB' "$HOME/.Renviron"; then
    echo "Warning: ~/.Renviron sets R_LIBS_USER without R_BIOC_LIB;" \
        "the launchers' library choice will be ignored" >&2
fi
