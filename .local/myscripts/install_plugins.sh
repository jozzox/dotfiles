#!/bin/bash

# This script reads vscode_plugins.md and installs the extensions listed.

# Check if the 'code' command is available
if ! command -v code &> /dev/null
then
    echo "The 'code' command could not be found. Please ensure Visual Studio Code is installed and in your PATH."
    exit 1
fi

# Read the markdown file, extract extension IDs (text within backticks),
# and install them one by one.
grep -o '`[^`]*`' vscode_plugins.md | tr -d '`' | while IFS= read -r extension; do
  if [ -n "$extension" ]; then
    echo "Installing $extension..."
    code --install-extension "$extension"
  fi
done

echo "All extensions have been processed."
