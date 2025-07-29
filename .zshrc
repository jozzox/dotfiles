# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light jeffreytse/zsh-vi-mode

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found
zinit snippet OMZP::podman
#zinit snippet OMZP::docker

# Fix for compinit error with stale completion cache
# This prevents errors from missing completion files
if [ -f "$HOME/.zcompdump" ]; then
    # Check for various problematic completion files that might cause errors
    if grep -q '_yfm\|_missing_\|_nonexistent' "$HOME/.zcompdump" 2>/dev/null; then
        echo "Stale completion cache detected. Cleaning up..."
        rm -f "$HOME/.zcompdump"*
        [ -d "${ZINIT_HOME%/*}/completions" ] && rm -rf "${ZINIT_HOME%/*}/completions"
        echo "Completion caches cleared."
    fi
fi

# Load completions with security check
autoload -Uz compinit && compinit -u

# Disable the cursor style feature
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE

#######################################################
# ZSH Basic Options
#######################################################

setopt autocd              # change directory just by typing its name
setopt correct             # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

#######################################################
# Environment Variables
#######################################################
export EDITOR="nvim"
export VISUAL="nvim"
export SUDO_EDITOR=nvim
export FCEDIT=nvim
export TERMINAL=kitty
export BROWSER=com.brave.Browser


if [[ -x "$(command -v bat)" ]]; then
	export MANPAGER="sh -c 'col -bx | bat -l man -p'"
	export PAGER=bat
fi

if [[ -x "$(command -v fzf)" ]]; then
	export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
	  --info=inline-right \
	  --ansi \
	  --layout=reverse \
	  --border=rounded \
	  --color=border:#27a1b9 \
	  --color=fg:#c0caf5 \
	  --color=gutter:#16161e \
	  --color=header:#ff9e64 \
	  --color=hl+:#2ac3de \
	  --color=hl:#2ac3de \
	  --color=info:#545c7e \
	  --color=marker:#ff007c \
	  --color=pointer:#ff007c \
	  --color=prompt:#2ac3de \
	  --color=query:#c0caf5:regular \
	  --color=scrollbar:#27a1b9 \
	  --color=separator:#ff9e64 \
	  --color=spinner:#ff007c \
	"
fi

# ZSH Keybindings
bindkey -v
#bindkey "^[[A" history-beginning-search-backward  # search history with up key
#bindkey "^[[B" history-beginning-search-forward   # search history with down key

# History Configuration
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':completion:*:*:podman-*:*' option-stacking yes

# Add Common Binary Directories to Path
# Add directories to the end of the path if they exist and are not already in the path
# Link: https://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there
function pathappend() {
    for ARG in "$@"
    do
        if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
            PATH="${PATH:+"$PATH:"}$ARG"
        fi
    done
}

# Add directories to the beginning of the path if they exist and are not already in the path
function pathprepend() {
    for ARG in "$@"
    do
        if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
            PATH="$ARG${PATH:+":$PATH"}"
        fi
    done
}

# Add the most common personal binary paths located inside the home folder
# (these directories are only added if they exist)
local -a user_paths
user_paths=(
    "$HOME/.bun/bin"
    "$HOME/.deno/bin"
    "$HOME/.dprint/bin"
    "$HOME/bin"
    "$HOME/sbin"
    "$HOME/.local/bin"
    "$HOME/local/bin"
    "$HOME/.bin"
    "$HOME/.local/myscripts"
    "$(go env GOPATH)/bin"
)
pathprepend "${user_paths[@]}"

# Check for the Rust package manager binary install location
# Link: https://doc.rust-lang.org/cargo/index.html
pathappend "$HOME/.cargo/bin"

#Yazi
# y shell wrapper that provides the ability to change the current working directory when exiting Yazi.
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# tiny-nvim explizit starten mit eigenem Alias mit neovim
alias visudo='EDITOR="nvim" visudo'
alias tiny-nvim='NVIM_APPNAME=tiny-jx-nvim nvim'

# Alias for neovim
if [[ -x "$(command -v nvim)" ]]; then
	alias vi='nvim'
	alias vim='nvim'
	alias svi='sudo nvim'
	alias vis='nvim "+set si"'
elif [[ -x "$(command -v vim)" ]]; then
	alias vi='vim'
	alias svi='sudo vim'
	alias vis='vim "+set si"'
fi

# Alias Sytem
alias sz='source ~/.zshrc'
alias szu='zinit update'
alias syu='sudo dnf upgrade'
alias syi='sudo dnf -y install'
alias ping='grc ping -c 5'
alias nmap='grc nmap'
alias ssc='grc ss'

# Alias tools
alias c='clear'
alias q='exit'
#
#alias ..='cd ..'
alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias rmdir='rmdir -v'
#
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
#
alias df='df -h'
alias du='du -h --max-depth=1'
alias free='free -h'
alias lsof='lsof -nP'
alias ps='ps -ef'
alias psaux='ps aux'
alias psauxf='ps auxf'

# Alias for lsd
if [[ -x "$(command -v lsd)" ]]; then
	alias ls='lsd -F --group-dirs first'
	alias ll='lsd --all --header --long --group-dirs first'
	alias tree='lsd --tree'
fi

# Alias For bat
# Link: https://github.com/sharkdp/bat
if [[ -x "$(command -v bat)" ]]; then
    alias cat='bat'
fi

# Alias for lazygit
# Link: https://github.com/jesseduffield/lazygit
if [[ -x "$(command -v lazygit)" ]]; then
    alias lg='lazygit'
fi

# Alias for FZF
# Link: https://github.com/junegunn/fzf
if [[ -x "$(command -v fzf)" ]]; then
    alias fzf='fzf --preview "bat --style=numbers --color=always --line-range :500 {}"'
    # Alias to fuzzy find files in the current folder(s), preview them, and launch in an editor
	if [[ -x "$(command -v xdg-open)" ]]; then
		alias preview='open $(fzf --info=inline --query="${@}")'
	else
		alias preview='edit $(fzf --info=inline --query="${@}")'
	fi
fi

# ZSH Syntax highlighting
source ~/.config/zsh/zsh-syntax-highlightin-tokyonight.zsh

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Installation für oh-my-posh Zen
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"

# Load local config-keys if it exists
[[ -f "$HOME/.zshrc.local" ]] && . "$HOME/.zshrc.local"

# Load environment variables from .env file if it exists (robust, unterstützt auch Leerzeichen)
if [[ -f "$HOME/.env" ]]; then
  set -a
  source "$HOME/.env"
  set +a
fi

# bun completions
[ -s "/home/tux/.bun/_bun" ] && source "/home/tux/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"

# Mise
eval "$(mise activate zsh)"
