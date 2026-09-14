# zsh config without a framework. Homebrew env is set in ~/.zprofile.

export EDITOR=nvim
export VISUAL=nvim
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export CLICOLOR=1

typeset -U path
path=($HOME/.local/bin $path)

# History
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt extended_history share_history hist_ignore_dups hist_ignore_space hist_verify hist_reduce_blanks

# Options
setopt auto_cd auto_pushd pushd_ignore_dups pushd_silent interactive_comments no_beep

# Key bindings: emacs style, Up/Down search history by typed prefix
bindkey -e
autoload -U up-line-or-beginning-search down-line-or-beginning-search edit-command-line
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
zle -N edit-command-line
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^P' up-line-or-beginning-search
bindkey '^N' down-line-or-beginning-search
bindkey '^X^E' edit-command-line

# Completion
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
autoload -Uz compinit && compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# increase limit of open files
ulimit -S -n 2048

alias ll='ls -lh'
alias la='ls -lAh'
alias nbstrip_jq="jq --indent 1 \
    '(.cells[] | select(has(\"outputs\")) | .outputs) = []  \
    | (.cells[] | select(has(\"execution_count\")) | .execution_count) = null  \
    | .metadata = {\"language_info\": {\"name\": \"python\", \"pygments_lexer\": \"ipython3\"}} \
    | .cells[].metadata = {} \
    '"

# Machine-local settings and secrets (API keys), not tracked in git.
[[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local

# Prompt and plugins (Homebrew). Syntax highlighting must be sourced last.
BREW="${HOMEBREW_PREFIX:-/opt/homebrew}"
(( $+commands[starship] )) && eval "$(starship init zsh)"
[[ ! -f $BREW/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] || source $BREW/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ ! -f $BREW/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] || source $BREW/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
