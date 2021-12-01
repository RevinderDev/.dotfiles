#!/usr/bin/env bash

# In all honesty, cba writing platform dependend tools so it's going to stay
# this way and you will have to install everything manually. Not like you
# do this often.


# Python related
# Install newest python version
pyenv
pipx
pipenv
# Install everything else python related using pipx
pipx install youtube-dl
pipx install pre-commit
pipx install black

# Rust related
## Compiler/Build
rustup
cargo
rustc
## Tools
clippy
rustftm

cargo install ripgrep           # grep replacement
cargo install exa               # ls replacement
cargo install git-delta         # git diff replacement
cargo install --locked bat      # cat replacement


# Development
lazygit
autohotkey
pycharm-community
codium                          # Vscode replacement
git
git-lfs
nvim
lua

# Shell related
oh-my-zsh
## Starhsip
sh -c "$(curl -fsSL https://starship.rs/install.sh)"
