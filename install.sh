#!/bin/bash
sh <(curl https://j.mp/spf13-vim3 -L)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
ln -s ~/dotfiles/tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/ctags ~/ctags
ln -s ~/dotfiles/zpreztorc ~/.zpreztorc
ln -s ~/dotfiles/zshrc ~/.zshrc
ln -s ~/dotfiles/ctags ~/ctags
ln -s ~/dotfiles/vim/gvimrc.local ~/.gvimrc.local
ln -s ~/dotfiles/vim/vimrc.before.local ~/.vimrc.before.local
ln -s ~/dotfiles/vim/vimrc.bundles.local ~/.vimrc.bundles.local
ln -s ~/dotfiles/vim/vimrc.local ~/.vimrc.local
if [ "$(uname)" == "Darwin"  ]; then
    brew update
    brew install reattach-to-user-namespace
    ln -s ~/dotfiles/hammerspoon ~/.hammerspoon
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux"  ]; then
    echo "linux"
fi
vim +BundleInstall! +BundleClean +q
