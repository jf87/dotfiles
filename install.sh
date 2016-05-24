#!/bin/bash
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
    brew install zsh
    brew install macvim --with-lua
    brew install reattach-to-user-namespace
    ln -s ~/dotfiles/hammerspoon ~/.hammerspoon
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux"  ]; then
    echo "linux"
    sudo apt-get install zsh
    sudo apt-get install tmux
    sudo apt-get install vim-gnome
fi
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
chsh -s /bin/zsh
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
sh <(curl https://j.mp/spf13-vim3 -L)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
vim +BundleInstall! +BundleClean +q
