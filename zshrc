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

if [[ `uname` == 'Linux' ]]
then
    export EDITOR=/usr/bin/vim
    export VISUAL=/usr/bin/vim
    # https://github.com/seebi/dircolors-solarized
    eval `dircolors /$HOME/.dir_colors/dircolors`
else

    if [[ `uname` == 'Darwin' ]]
    then
            export EDITOR=/usr/local/bin/vim
            export VISUAL=/usr/local/bin/vim
    fi
fi

export CCNL_HOME=$HOME/src/ccn-lite


export GOPATH=$HOME/go
path=(
  /Users/jofu/google-cloud-sdk/bin
  $path
  $HOME/.yadr/bin
  $HOME/.yadr/bin/yadr
  $GOPATH/bin
  $CCNL_HOME/bin
  /usr/local/go/bin
  $HOME/.npm-packages/bin
)


# Keep Virtualenv in new tmux panes or windows
#if [ -n "$VIRTUAL_ENV" ]; then
    #source $VIRTUAL_ENV/bin/activate
#fi


# this fixes hidden cursor problem on gnome terminal
# see https://github.com/zsh-users/zsh-syntax-highlighting/issues/171
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[cursor]=underline

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
alias emacs='emacs -nw'
#alias vim='nvim'
alias nvimtex='NVIM_LISTEN_ADDRESS=/tmp/nvim_tex.sock nvim'

# increase limit of open files
ulimit -S -n 1024
