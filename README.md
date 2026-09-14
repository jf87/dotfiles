# dotfiles

macOS setup: zsh (prezto + powerlevel10k), tmux, Hammerspoon, iTerm2, apps via Brewfile.
Neovim config lives in [jf87/kickstart.nvim](https://github.com/jf87/kickstart.nvim).

## New Mac

1. Update macOS, then `xcode-select --install`.
2. Create an SSH key (`ssh-keygen -t ed25519`) and add it to GitHub.
3. `git clone git@github.com:jf87/dotfiles ~/dotfiles && ~/dotfiles/install.sh`
4. Put API keys (from KeePassXC) into `~/.zshrc.local`. Never commit secrets: this repo is public.
5. tmux: `prefix + I` to install plugins. nvim: start once to let Lazy and Mason install everything.
6. iTerm2: Settings → Profiles → set "Default" (dynamic profile) as default.
7. Raycast: Settings → Advanced → Import the `.rayconfig` export.
8. Hammerspoon: grant Accessibility access, enable launch at login.

## Hyper key

Caps Lock is remapped to F18 by `com.local.KeyRemapping.plist` (hidutil), and
Hammerspoon uses F18 as hyper key: https://www.naseer.dev/post/hidutil/

Check: `brew bundle check --file ~/dotfiles/Brewfile`
