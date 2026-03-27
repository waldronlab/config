# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias rm='rm -i'
alias del="$HOME/src/move_to_trash.sh"

## --- UPDATE THESE PATHS EACH BIOC RELEASE ---
_r() { local v=$1 lib=$2; shift 2; R_LIBS_USER=$HOME/R/$lib $HOME/src/svn/$v/inst/bin/R "$@"; }
alias Rold="_r r-4-4 bioc-oldrel --no-save --no-restore-data --no-environ"
alias Rrel="_r r-4-5 bioc-release --no-save --no-restore-data --no-environ"
alias Rdev="_r r-devel bioc-devel --no-save --no-restore-data --no-environ"

## --- UPDATE THESE PATHS EACH BIOC RELEASE ---
_rstu() { local v=$1 lib=$2; RSTUDIO_WHICH_R=$HOME/src/svn/$v/inst/bin/R R_LIBS_USER=$HOME/R/$lib rstudio; }
alias rstuold="_rstu r-4-4 bioc-oldrel"
alias rsturel="_rstu r-4-5 bioc-release"
alias rstudev="_rstu r-devel bioc-devel"

## If you need independent R libraries for testing
## alias r45="R_LIBS_USER=$HOME/R/r-4-5 $HOME/src/svn/r-4-5/inst/bin/R --no-save --no-restore-data --no-environ"
## alias devel="R_LIBS_USER=$HOME/R/r-devel $HOME/src/svn/r-devel/inst/bin/R --no-save --no-restore-data --no-environ"

alias INSTALL='Rdev CMD INSTALL --no-test-load --no-staged-install'

alias buildr='Rrel CMD build --no-build-vignettes'
alias buildd='Rdev CMD build --no-build-vignettes'

alias checkr='time Rrel CMD check --no-vignettes --no-manual'
alias checkd='time Rdev CMD check --no-vignettes --no-manual'

alias bioccheck='Rdev -e "BiocCheck::BiocCheck()"'

## --- UPDATE THESE PATHS EACH BIOC RELEASE ---
_vim() { local v=$1 lib=$2; shift 2; R_LIBS_USER=$HOME/R/$lib RLOC=$HOME/src/svn/$v/inst/bin vim "$@"; }
alias vimo="_vim r-4-4 bioc-oldrel"
alias vimr="_vim r-4-5 bioc-release"
alias vimd="_vim r-devel bioc-devel"

alias locate='locate -i'
alias sudo='sudo '
alias tmux="TERM=screen-256color-bce tmux"

alias fullpath='readlink -f'
alias bump="$HOME/bin/version_bump.sh"

if [ -x /usr/bin/subversion ]; then
    alias svnvimdiff="svn diff -r PREV | view -"
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f $HOME/src/google-cloud-sdk/path.bash.inc ]; then
  source $HOME/src/google-cloud-sdk/path.bash.inc
fi

# The next line enables shell command completion for gcloud.
if [ -f $HOME/src/google-cloud-sdk/completion.bash.inc ]; then
  source $HOME/src/google-cloud-sdk/completion.bash.inc
fi

alias gitall="find . -maxdepth 1 -mindepth 1 -type d -exec sh -c '(echo {} && cd {} && git status -s && echo)' \;"
alias git.addnw="git diff -U0 -w --no-color --src-prefix=a/ --dst-prefix=b/ | git apply --cached --ignore-whitespace --unidiff-zero -"
alias scrub='find . -maxdepth 1 -type f -name "*.tar.gz" -exec rm {} \; && find . -maxdepth 1 -type d -name "*.Rcheck" -exec rm -rf {} \; && find . -maxdepth 1 -type d -name "*.BiocCheck" -exec rm -rf {} \;'

