export PATH="$HOME/.local/bin:$PATH"

autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# colorize ls output (BSD ls on macOS): directories bold blue, symlinks bold cyan, executables bold green
export CLICOLOR=1
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd
# use the same colors in tab completion menus
zstyle ':completion:*' list-colors 'di=1;34:ln=1;36:so=1;31:pi=1;33:ex=1;32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

# load shared aliases (e.g., Rrel, Rdev)
[ -f "$HOME/.bash_aliases" ] && source "$HOME/.bash_aliases"
