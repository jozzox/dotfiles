#!/bin/bash

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${2}${1}${NC}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if required commands exist
if ! command_exists git; then
    print_message "Error: git is not installed. Please install git first." "$RED"
    exit 1
fi

if ! command_exists nvim; then
    print_message "Error: nvim is not installed. Please install Neovim first." "$RED"
    exit 1
fi

# Parse command line arguments
APPNAME="tiny-nvim"
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --appname) APPNAME="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Backup existing config if it exists
if [ -d "$HOME/.config/$APPNAME" ]; then
    print_message "Backing up existing Neovim configuration..." "$YELLOW"
    backup_dir="$HOME/.config/${APPNAME}_backup_$(date +%Y%m%d_%H%M%S)"
    mv "$HOME/.config/$APPNAME" "$backup_dir"
    print_message "Backup created at: $backup_dir" "$GREEN"
fi

# Clone the repository directly to config directory
print_message "Cloning configuration repository..." "$YELLOW"
git clone https://github.com/jozzox/tiny-nvim.git "$HOME/.config/$APPNAME"

# Run the installation scripts
print_message "Installing tools..." "$YELLOW"
if [ -f "$HOME/.config/$APPNAME/scripts/install-tools.sh" ]; then
    chmod +x "$HOME/.config/$APPNAME/scripts/install-tools.sh"
    "$HOME/.config/$APPNAME/scripts/install-tools.sh"
else
    print_message "Warning: install-tools.sh not found, skipping..." "$YELLOW"
fi

# Install plugins using lazy.nvim
print_message "Installing plugins..." "$YELLOW"
cd "$HOME/.config/$APPNAME" || exit 1
NVIM_APPNAME=$APPNAME nvim --headless -c "Lazy install" -c "qa"

print_message "Installation completed successfully! 🎉" "$GREEN"
print_message "You can now start Neovim with your new configuration using:" "$GREEN"
if [ "$APPNAME" != "nvim" ]; then
    print_message "NVIM_APPNAME=$APPNAME" "$YELLOW"
else
    print_message "nvim" "$YELLOW"
fi

print_message "To clean up this configuration later, you can run:" "$YELLOW"
print_message "rm -rf ~/.config/$APPNAME" "$YELLOW"
print_message "rm -rf ~/.local/share/$APPNAME" "$YELLOW"
print_message "rm -rf ~/.cache/$APPNAME" "$YELLOW"
print_message "rm -rf ~/.local/state/$APPNAME" "$YELLOW"
