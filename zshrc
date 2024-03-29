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
#alias tmux='tmux -2'

if [[ `uname` == 'Linux' ]]
then
    export EDITOR=/usr/bin/vim
    export VISUAL=/usr/bin/vim
    # https://github.com/seebi/dircolors-solarized
    eval `dircolors /$HOME/.dir_colors/dircolors`
    # disable capslock key
    setxkbmap -option caps:none
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

export CONDA_AUTO_ACTIVATE_BASE=false
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
#alias vim='nvim'
alias nvimtex='NVIM_LISTEN_ADDRESS=/tmp/nvim_tex.sock nvim'

# increase limit of open files
ulimit -S -n 2048

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Applications/google-cloud-sdk/path.zsh.inc' ]; then . '/Applications/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Applications/google-cloud-sdk/completion.zsh.inc' ]; then . '/Applications/google-cloud-sdk/completion.zsh.inc'; fi

#export JAVA_HOME="JAVA_HOME=/Applications/Android Studio.app/Contents/jre/jdk/Contents/Home/"

#export NVM_DIR="$HOME/.nvm"
#[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
#[ -s "/usr/local/opt/nvm/etc/bash_completion" ] && . "/usr/local/opt/nvm/etc/bash_completion"  # This loads nvm bash_completion

alias pyconda="/usr/local/miniconda3/bin/python"
alias condainit='export PATH="/usr/local/miniconda3/bin:$PATH"'
alias condaexit='source /etc/profile'


alias nbstrip_jq="jq --indent 1 \
    '(.cells[] | select(has(\"outputs\")) | .outputs) = []  \
    | (.cells[] | select(has(\"execution_count\")) | .execution_count) = null  \
    | .metadata = {\"language_info\": {\"name\": \"python\", \"pygments_lexer\": \"ipython3\"}} \
    | .cells[].metadata = {} \
    '"



#. /usr/local/miniconda3/etc/profile.d/conda.sh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/usr/local/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/usr/local/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/usr/local/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/usr/local/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"
