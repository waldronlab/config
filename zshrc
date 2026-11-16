export PATH="$HOME/.local/bin:$PATH"
# macOS R toolchain (as on the Bioconductor build machines; see buildr/README.md)
[ -d /opt/R/arm64/bin ] && export PATH="/opt/R/arm64/bin:$PATH"
[ -d /opt/gfortran/bin ] && export PATH="/opt/gfortran/bin:$PATH"

export GITHUB=$HOME/gh

# history (bashrc: HISTCONTROL=ignoreboth, histappend)
HISTFILE=${HISTFILE:-$HOME/.zsh_history}
HISTSIZE=2000
SAVEHIST=2000
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE APPEND_HISTORY

autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
# bashrc/inputrc: TAB cycles through matches (menu-complete) and lists them
setopt MENU_COMPLETE
zstyle ':completion:*' menu select

# colorize ls output (BSD ls on macOS): directories bold blue, symlinks bold cyan, executables bold green
export CLICOLOR=1
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd
# use the same colors in tab completion menus
zstyle ':completion:*' list-colors 'di=1;34:ln=1;36:so=1;31:pi=1;33:ex=1;32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

# colored grep output
alias grep='grep --color=auto'
export GREP_COLORS='mt=1;32:fn=35:ln=32:se=36'

# vi editing mode (inputrc: editing-mode vi) with bar/block cursor per mode
bindkey -v
export KEYTIMEOUT=1
zle-keymap-select() {
    if [[ $KEYMAP == vicmd ]]; then printf '\e[1 q'; else printf '\e[5 q'; fi
}
zle-line-init() { printf '\e[5 q'; }
zle -N zle-keymap-select
zle -N zle-line-init

# prompt: user@host cwd (branch) $  -- same as bashrc's parse_git_branch
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' (%b)'
zstyle ':vcs_info:git:*' actionformats ' (%b|%a)'
precmd() { vcs_info }
setopt PROMPT_SUBST
PROMPT='%n@%m %F{green}%~%f%F{yellow}${vcs_info_msg_0_}%f $ '

# load shared aliases (e.g., Rrel, Rdev)
[ -f "$HOME/.bash_aliases" ] && source "$HOME/.bash_aliases"
