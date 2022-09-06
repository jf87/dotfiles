#!/bin/bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew install python3 node tmux zsh neovim vim go
brew install --cask hammerspoon keepassxc syncthing spotify
