#!/bin/bash
# Create RStudio launchers, one per R / Bioconductor setup (Linux / Mac)
#
# Each launcher starts RStudio with
#   RSTUDIO_WHICH_R = $HOME/src/svn/<R build>/inst/bin/R   (see buildr/)
#   R_BIOC_LIB      = $HOME/R/<library>
#
#   Linux: app-menu entries in ~/.local/share/applications
#   macOS: small apps "RStudio <name>.app" in ~/Applications (Spotlight,
#          Launchpad; drag them to the Dock to pin)
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

# Linux only: setup used when opening .R/.Rproj files. Overrides
# /usr/share/applications/rstudio.desktop with a user copy that is hidden
# from the app menu (NoDisplay), so only the launchers above are shown.
# Set to "" to restore the system "RStudio" launcher.
# (On macOS, RStudio.app keeps opening files with the ~/.Renviron default.)
DEFAULT="Dev"

MARKER="X-Generated-By=rstudio-launchers.sh"

set -euo pipefail

check_setup() {  # warn about missing R builds / libraries
    [[ -x $1 ]] || echo "Warning: no R at $1" >&2
    [[ -d $2 ]] || echo "Warning: no library at $2" >&2
}

linux_launchers() {
    local RSTUDIO=/usr/lib/rstudio/rstudio
    local SYSTEM_DESKTOP=/usr/share/applications/rstudio.desktop
    local APPDIR=$HOME/.local/share/applications
    local setup name rbuild lib rbin libdir file f
    mkdir -p "$APPDIR"

    # Remove launchers created by earlier runs so renamed setups don't linger
    for f in "$APPDIR"/rstudio-*.desktop "$APPDIR/rstudio.desktop"; do
        [[ -e $f ]] && grep -qx "$MARKER" "$f" && rm -v "$f"
    done

    if [[ $REMOVE == 1 ]]; then
        command -v update-desktop-database >/dev/null &&
            update-desktop-database "$APPDIR"
        return 0
    fi

    [[ -x $RSTUDIO ]] || echo "Warning: RStudio not found at $RSTUDIO" >&2

    for setup in "${SETUPS[@]}"; do
        IFS=: read -r name rbuild lib <<< "$setup"
        rbin=$HOME/src/svn/$rbuild/inst/bin/R
        libdir=$HOME/R/$lib
        file=$APPDIR/rstudio-$lib.desktop
        check_setup "$rbin" "$libdir"

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
}

macos_launchers() {
    local RSTUDIO_APP=/Applications/RStudio.app
    local APPDIR=$HOME/Applications
    local BUNDLE_ID=org.waldronlab.rstudio-launcher
    local LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
    local setup name rbuild lib rbin libdir app icon f
    mkdir -p "$APPDIR"

    # Remove apps created by earlier runs (identified by their bundle id)
    for f in "$APPDIR"/RStudio*.app; do
        if [[ -f $f/Contents/Info.plist ]] &&
            grep -q "<string>$BUNDLE_ID\." "$f/Contents/Info.plist"; then
            [[ -x $LSREGISTER ]] && "$LSREGISTER" -u "$f" || true
            rm -rf "$f" && echo "removed '$f'"
        fi
    done

    [[ $REMOVE == 1 ]] && return 0

    [[ -d $RSTUDIO_APP ]] || echo "Warning: RStudio not found at $RSTUDIO_APP" >&2
    icon=$(ls "$RSTUDIO_APP"/Contents/Resources/*.icns 2>/dev/null | head -1 || true)

    for setup in "${SETUPS[@]}"; do
        IFS=: read -r name rbuild lib <<< "$setup"
        rbin=$HOME/src/svn/$rbuild/inst/bin/R
        libdir=$HOME/R/$lib
        app="$APPDIR/RStudio $name.app"
        check_setup "$rbin" "$libdir"

        mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
        [[ -n $icon ]] && cp "$icon" "$app/Contents/Resources/rstudio.icns"

        # Apps started from the Dock/Spotlight don't see shell variables, so
        # pass them with 'open --env'; -n starts a separate RStudio instance
        cat > "$app/Contents/MacOS/launcher" <<EOF
#!/bin/bash
# RStudio with $rbuild and the ~/R/$lib library ($MARKER)
exec /usr/bin/open -n -a "$RSTUDIO_APP" \\
    --env "RSTUDIO_WHICH_R=$rbin" \\
    --env "R_BIOC_LIB=$libdir" "\$@"
EOF
        chmod +x "$app/Contents/MacOS/launcher"

        # LSUIElement: the launcher itself doesn't bounce in the Dock
        cat > "$app/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>RStudio $name</string>
    <key>CFBundleDisplayName</key>
    <string>RStudio $name</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID.$(echo "$name" | tr '[:upper:]' '[:lower:]')</string>
    <key>CFBundleExecutable</key>
    <string>launcher</string>
    <key>CFBundleIconFile</key>
    <string>rstudio</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF
        [[ -x $LSREGISTER ]] && "$LSREGISTER" -f "$app" || true
        echo "Created $app"
    done
}

REMOVE=0
[[ ${1:-} == "--remove" ]] && REMOVE=1

case "$(uname -s)" in
    Linux) linux_launchers ;;
    Darwin) macos_launchers ;;
    *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

[[ $REMOVE == 1 ]] && exit 0

if [[ -f $HOME/.Renviron ]] &&
    grep -q '^R_LIBS_USER=' "$HOME/.Renviron" &&
    ! grep -q '^R_LIBS_USER=.*R_BIOC_LIB' "$HOME/.Renviron"; then
    echo "Warning: ~/.Renviron sets R_LIBS_USER without R_BIOC_LIB;" \
        "the launchers' library choice will be ignored" >&2
fi
