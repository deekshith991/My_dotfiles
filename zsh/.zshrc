# Start configuration added by Zim install {{{
#
# User configuration sourced by interactive shells
#

# -----------------
# Zsh configuration
# -----------------

#
# History
#

# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

#
# Input/output
#

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -v

# Prompt for spelling correction of commands.
#setopt CORRECT

# Customize spelling correction prompt.
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# -----------------
# Zim configuration
# -----------------

# Use degit instead of git as the default tool to install and update modules.
zstyle ':zim:zmodule' use 'degit'

# --------------------
# Module configuration
# --------------------

#
# git
#

# Set a custom prefix for the generated aliases. The default prefix is 'G'.
#zstyle ':zim:git' aliases-prefix 'g'

#
# input
#

# Append `../` to your input for each `.` you type after an initial `..`
#zstyle ':zim:input' double-dot-expand yes

#
# termtitle
#

# Set a custom terminal title format using prompt expansion escape sequences.
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
# If none is provided, the default '%n@%m: %~' is used.
#zstyle ':zim:termtitle' format '%1~'

#
# zsh-autosuggestions
#

# Disable automatic widget re-binding on each precmd. This can be set when
# zsh-users/zsh-autosuggestions is the last module in your ~/.zimrc.
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Customize the style that the suggestions are shown with.
# See https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#suggestion-highlight-style
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

#
# zsh-syntax-highlighting
#

# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Customize the main highlighter styles.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
#typeset -A ZSH_HIGHLIGHT_STYLES
#ZSH_HIGHLIGHT_STYLES[comment]='fg=242'

# ------------------
# Initialize modules
# ------------------

ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi
# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh

# ------------------------------
# Post-init module configuration
# ------------------------------

#
# zsh-history-substring-search
#

zmodload -F zsh/terminfo +p:terminfo
# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key
# }}} End configuration added by Zim install

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# ---------------------------- Personal settings --------------------------------------



# ---------------------------- proxy ----------------------

PROXY_ON=false
PROXY_URL="http://staffnet.rgukt.ac.in:3128"

proxy_on() {
  export http_proxy=$PROXY_URL
  export https_proxy=$PROXY_URL
  export ftp_proxy=$PROXY_URL
  export no_proxy="localhost,127.0.0.1"
  PROXY_ON=true
  echo "Proxy is now ON"
}

proxy_off() {
  unset http_proxy
  unset https_proxy
  unset ftp_proxy
  unset no_proxy
  PROXY_ON=false
  echo "Proxy is now OFF"
}

toggle_proxy() {
  if [ "$PROXY_ON" = false ]; then
    proxy_on
  else
    proxy_off
  fi
}

# ------------------------- aliasing ---------------------------
alias ls="eza --icons"
alias l="ls"
alias ll="ls -la"

alias cd="z "
alias cd.="cd ../"
alias cd..="cd ../../"
alias cd...="cd ../../../"
alias cd....="cd ../../../../"

## tools
alias cat="batcat"
alias help="tldr"
alias ytdl="/opt/yt-download/YoutubeDownloader"

alias reload-zsh="source ~/.zshrc"
alias edit-zsh="nvim ~/.zshrc"

alias lG="lazygit"

## service aliases 
alias stop-mongo="systemctl stop mongod.service"
alias start-mongo="systemctl start mongod.service"
alias mongost="systemctl status mongod.service"

alias aptU="sudo apt update && sudo apt upgrade"

## tmux aliases 
alias tn="tmux -u new -s"
alias ta="tmux attach-session -t"
alias tkill="tmux kill-session -t"
alias twkill="tmux kill-window -t"
alias tls="tmux ls"

alias gt="cd github"

# -------------------------- neovim -----------------------------

alias nvim-lazy="NVIM_APPNAME=LazyVim nvim"
alias nvim-astro="NVIM_APPNAME=AstroNvim nvim"
alias nv="NVIM_APPNAME=my-default-nvim nvim"
alias v="NVIM_APPNAME=default nvim"
alias nt="NVIM_APPNAME=testing nvim"

function nvims() {
  items=("default" "my-default-nvim" "LazyVim" "testing" "bare" "AstroNvim")
  config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config  " --height=~50% --layout=reverse --border --exit-0)
  if [[ -z $config ]]; then
    echo "Nothing selected"
    return 0
  elif [[ $config == "default" ]]; then
    config=""
  fi
  NVIM_APPNAME=$config nvim $@
}

# bindkey -s ^n "nvims\n"



# -------------------------- sourcing --------------------------------

eval "$(starship init zsh)"
eval "$(direnv hook zsh)"
eval "$(zoxide init zsh)"
source <(fzf --zsh) # Set up fzf key bindings and fuzzy completion

export PATH=/run/current-system/sw/bin:$HOME/.nix-profile/bin:$PATH
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi


# --------------------- Running commands ----------------------------

clear
# if [[ ! -v TMUX && $TERM_PROGRAM != "vscode" ]]; then
# 	~/tmux_chooser && exit
# fi

# ------------------------------ Depriciated ------------------------------

# alias windows="cd /media/deekshith/0804797804796998/Users/Deekshith"

# ---------------- Add any additional configurations here ------------------

