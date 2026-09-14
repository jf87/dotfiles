#!/bin/zsh
# macOS setup. Safe to re-run.
set -e
DOT="$HOME/dotfiles"

# Homebrew
if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
# Don't stop the whole setup if a single app fails to install
brew bundle --file "$DOT/Brewfile" || echo "WARNING: some Brewfile entries failed (see above); continuing setup."

# Symlinks
link() { mkdir -p "$(dirname "$2")"; ln -sfn "$DOT/$1" "$2"; }
link zshrc                 "$HOME/.zshrc"
link zprofile              "$HOME/.zprofile"
link starship.toml         "$HOME/.config/starship.toml"
link tmux.conf             "$HOME/.tmux.conf"
link vimrc                 "$HOME/.vimrc"
link gitconfig             "$HOME/.gitconfig"
link latexmkrc             "$HOME/.latexmkrc"
link hammerspoon           "$HOME/.hammerspoon"
link claude/settings.json  "$HOME/.claude/settings.json"

# iTerm2 profile (loaded as a dynamic profile)
link iterm2/profiles.json "$HOME/Library/Application Support/iTerm2/DynamicProfiles/profiles.json"

# Remove leftovers of the old prezto/p10k setup (dangling or prezto symlinks)
for rc in zshenv zlogin zlogout zpreztorc flake8; do
    f="$HOME/.$rc"
    if [[ -L "$f" && ( ! -e "$f" || "$(readlink "$f")" == *zprezto* ) ]]; then
        rm "$f"
    fi
done

# Neovim config
if [[ ! -d "$HOME/.config/nvim" ]]; then
    git clone git@github.com:jf87/kickstart.nvim.git "$HOME/.config/nvim"
fi

# Python tools
uv tool install --upgrade neovim-remote

# Claude Code CLI (native installer, auto-updates, installs to ~/.local/bin)
if [[ ! -x "$HOME/.local/bin/claude" ]]; then
    curl -fsSL https://claude.ai/install.sh | bash
fi

# Caps Lock -> F18 (hyper key for Hammerspoon)
cp "$DOT/com.local.KeyRemapping.plist" "$HOME/Library/LaunchAgents/"
launchctl unload "$HOME/Library/LaunchAgents/com.local.KeyRemapping.plist" 2>/dev/null || true
launchctl load "$HOME/Library/LaunchAgents/com.local.KeyRemapping.plist"

# Secrets file
if [[ ! -f "$HOME/.zshrc.local" ]]; then
    touch "$HOME/.zshrc.local" && chmod 600 "$HOME/.zshrc.local"
    echo "Created ~/.zshrc.local - add API keys from KeePassXC."
fi

echo "Done. Next: open nvim once to install plugins."
