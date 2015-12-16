#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...

#force 256 colors
alias tmux='tmux -2'

export EDITOR=/usr/local/bin/vim
export VISUAL=/usr/local/bin/vim

export GOPATH=$HOME/Dropbox/12-coding/go
path=(
  $path
    $HOME/.yadr/bin
      $HOME/.yadr/bin/yadr
        $GOPATH/bin

)

