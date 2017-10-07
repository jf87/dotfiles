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

export CCNL_HOME=$HOME/src/ccn-lite


export GOPATH=$HOME/go
path=(
  $path
  $HOME/.yadr/bin
  $HOME/.yadr/bin/yadr
  $GOPATH/bin
  $CCNL_HOME/bin
)

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
alias emacs='emacs -nw'
#alias vim='nvim'
alias nvimtex='NVIM_LISTEN_ADDRESS=/tmp/nvim_tex.sock nvim'

# increase limit of open files
ulimit -S -n 1024
