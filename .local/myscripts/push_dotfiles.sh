#!/bin/bash

set -euo pipefail

# Repos und URLs
REPO_BASE="$HOME/Repo"
DOTFILES_DIR="$REPO_BASE/dotfiles"
TINYNVIM_DOTFILES_DIR="$REPO_BASE/tiny-jx-nvim"
DOTFILES_URL="https://github.com/jozzox/dotfiles.git"
TINYNVIM_URL="https://github.com/jozzox/tiny-jx-nvim.git"

# Dotfiles-Repo initialisieren und pushen
if [ -d "$DOTFILES_DIR" ]; then
    cd "$DOTFILES_DIR"
    if [ ! -f README.md ]; then
        echo "# dotfiles" > README.md
    fi
    git init
    git add README.md
    git commit -m "first commit" || true
    git branch -M main
    git remote remove origin 2>/dev/null || true
    git remote add origin "$DOTFILES_URL"
    git push -u origin main || true
    echo "dotfiles-Repo wurde initialisiert und gepusht."
else
    echo "Verzeichnis $DOTFILES_DIR existiert nicht!"
fi

# Tiny JX Nvim-Repo initialisieren und pushen
if [ -d "$TINYNVIM_DOTFILES_DIR" ]; then
    cd "$TINYNVIM_DOTFILES_DIR"
    if [ ! -f README.md ]; then
        echo "# tiny-jx-nvim" > README.md
    fi
    git init
    git add README.md
    git commit -m "first commit" || true
    git branch -M main
    git remote remove origin 2>/dev/null || true
    git remote add origin "$TINYNVIM_URL"
    git push -u origin main || true
    echo "tiny-jx-nvim-Repo wurde initialisiert und gepusht."
else
    echo "Verzeichnis $TINYNVIM_DOTFILES_DIR existiert nicht!"
fi
