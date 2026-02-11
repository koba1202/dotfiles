#!/usr/bin/env bash

set -e

DOTFILES_DIR="$HOME/dotfiles"

echo "Creating symlinks..."

mkdir -p ~/.config

ln -sf "$DOTFILES_DIR/.config/nvim" ~/.config/nvim
ln -sf "$DOTFILES_DIR/.config/wezterm/.wezterm.lua" ~/.wezterm.lua
ln -sf "$DOTFILES_DIR/.config/starship.toml" ~/.config/starship.toml

echo "Done!"

