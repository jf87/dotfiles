#!/bin/zsh
# macOS setup. Safe to re-run.
set -e
DOT="$HOME/dotfiles"

# Homebrew
if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
brew bundle --file "$DOT/Brewfile"

# Prezto
if [[ ! -d "$HOME/.zprezto" ]]; then
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "$HOME/.zprezto"
fi
for rc in zshenv zprofile zlogin zlogout; do
    ln -sfn "$HOME/.zprezto/runcoms/$rc" "$HOME/.$rc"
done

# Symlinks
link() { mkdir -p "$(dirname "$2")"; ln -sfn "$DOT/$1" "$2"; }
link zshrc                 "$HOME/.zshrc"
link zpreztorc             "$HOME/.zpreztorc"
link p10k.zsh              "$HOME/.p10k.zsh"
link tmux.conf             "$HOME/.tmux.conf"
link vimrc                 "$HOME/.vimrc"
link gitconfig             "$HOME/.gitconfig"
link flake8                "$HOME/.flake8"
link latexmkrc             "$HOME/.latexmkrc"
link hammerspoon           "$HOME/.hammerspoon"
link claude/settings.json  "$HOME/.claude/settings.json"

# iTerm2 profile (loaded as a dynamic profile)
link iterm2/profiles.json "$HOME/Library/Application Support/iTerm2/DynamicProfiles/profiles.json"

# Neovim config
if [[ ! -d "$HOME/.config/nvim" ]]; then
    git clone git@github.com:jf87/kickstart.nvim.git "$HOME/.config/nvim"
fi

# tmux plugin manager (install plugins with prefix + I)
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# Python tools
uv tool install --upgrade neovim-remote

# Caps Lock -> F18 (hyper key for Hammerspoon)
cp "$DOT/com.local.KeyRemapping.plist" "$HOME/Library/LaunchAgents/"
launchctl unload "$HOME/Library/LaunchAgents/com.local.KeyRemapping.plist" 2>/dev/null || true
launchctl load "$HOME/Library/LaunchAgents/com.local.KeyRemapping.plist"

# Secrets file
if [[ ! -f "$HOME/.zshrc.local" ]]; then
    touch "$HOME/.zshrc.local" && chmod 600 "$HOME/.zshrc.local"
    echo "Created ~/.zshrc.local - add API keys from KeePassXC."
fi

echo "Done. Next: open tmux and press prefix + I; open nvim to install plugins."
