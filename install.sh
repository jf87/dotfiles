#!/bin/bash
ln -s -f ~/dotfiles/tmux.conf ~/.tmux.conf
ln -s -f ~/dotfiles/ctags ~/ctags
ln -s -f ~/dotfiles/zpreztorc ~/.zpreztorc
ln -s -f ~/dotfiles/zshrc ~/.zshrc
ln -s -f ~/dotfiles/ctags ~/ctags
ln -s -f ~/dotfiles/vim/vimrc ~/.vimrc
if [ "$(uname)" == "Darwin"  ]; then
    brew update
    brew install python3
    brew install tmux
    brew install zsh
    brew install neovim/neovim/neovim
    brew install reattach-to-user-namespace
    ln -s ~/dotfiles/hammerspoon ~/.hammerspoon
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux"  ]; then
    echo "linux"
    sudo apt-get install zsh
    sudo apt-get install tmux
    sudo apt-get install vim-gnome
    sudo apt-get install software-properties-common
    sudo add-apt-repository ppa:neovim-ppa/unstable
    sudo apt-get update
    sudo apt-get install neovim
    sudo apt-get install python-dev python-pip python3-dev python3-pip
    git clone https://github.com/Anthony25/gnome-terminal-colors-solarized ~/gnome-terminal-colors-solarized
    ~/gnome-terminal-colors-solarized/install.sh
fi
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
chsh -s /bin/zsh
exec zsh
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +BundleInstall! +BundleClean +q
sudo pip3 install neovim
sudo pip3 install --upgrade neovim
mkdir ~/.config
ln -s ~/.vim ~/.config/nvim
ln -s ~/.vimrc ~/.config/nvim/init.vim
nvim +UpdateRemotePlugins +GoInstallBinaries +q
