#!/bin/bash
# Wrapper for air to ensure it finds air.toml when called by RStudio
# RStudio passes the temporary file path as the last argument.
# Move file to ~/.local/bin/air-rstudio-wrapper.sh and use this
# as the air command in RStudio's Build Tools settings.

FILE_PATH="${@: -1}"
DIR_PATH=$(dirname "$FILE_PATH")

# Copy the user's global air.toml to the temporary directory
# so that air finds it when walking up from the temp file.
if [ -f "$HOME/air.toml" ] && [ ! -f "$DIR_PATH/air.toml" ]; then
    cp "$HOME/air.toml" "$DIR_PATH/air.toml"
fi

# Run air with the original arguments
/home/user/.local/bin/air "$@"

