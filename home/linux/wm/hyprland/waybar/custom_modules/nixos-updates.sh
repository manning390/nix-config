#!/usr/bin/env bash

# Ensure nvd is installed
if ! command -v nvd &> /dev/null; then
    echo '{"text": "nvd not found", "tooltip": "Please install nvd", "class": "error"}'
    exit 1
fi

# Check for updates
updates=$(nvd diff /run/current-system ~/dotfiles/flake.nix#nixosConfigurations.$(hostname).config.system.build.toplevel 2>/dev/null | grep '^[<>]' | wc -l)

if [ "$updates" -gt 0 ]; then
    echo "{\"text\": \"$updates\", \"tooltip\": \"$updates updates available\", \"class\": \"has-updates\"}"
else
    echo '{"text": "0", "tooltip": "System is up to date", "class": "up-to-date"}'
fi
