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

## Modify the R version folders (in src/svn) after every release
## Note. These folders correspond to ./buildr.sh
alias Rold="R_LIBS_USER=$HOME/R/bioc-oldrel $HOME/src/svn/r-4-1/R/bin/R --no-save --no-restore-data --no-environ"
alias Rrel="R_LIBS_USER=$HOME/R/bioc-release $HOME/src/svn/r-4-2/R/bin/R --no-save --no-restore-data --no-environ"
alias Rdev="R_LIBS_USER=$HOME/R/bioc-devel $HOME/src/svn/r-4-2/R/bin/R --no-save --no-restore-data"

alias rstudev="RSTUDIO_WHICH_R=$HOME/src/svn/r-devel/R/bin/R R_LIBS_USER=$HOME/R/bioc-devel rstudio --no-save --no-restore-data --no-environ"
alias rsturel="RSTUDIO_WHICH_R=$HOME/src/svn/r-release/R/bin/R R_LIBS_USER=$HOME/R/bioc-release rstudio --no-save --no-restore-data --no-environ"

## If you need independent R libraries for testing
## alias r40="R_LIBS_USER=$HOME/R/r-4-0 $HOME/src/svn/r-4-0/R/bin/R --no-save --no-restore-data --no-environ"
## alias r41="R_LIBS_USER=$HOME/R/r-4-1 $HOME/src/svn/r-4-1/R/bin/R --no-save --no-restore-data --no-environ"
## alias r42="R_LIBS_USER=$HOME/R/r-4-2 $HOME/src/svn/r-4-2/R/bin/R --no-save --no-restore-data --no-environ"
## alias devel="R_LIBS_USER=$HOME/R/r-devel $HOME/src/svn/r-devel/R/bin/R --no-save --no-restore-data --no-environ"

alias buildr='Rrel CMD build --no-build-vignettes'
alias buildd='Rdev CMD build --no-build-vignettes'
alias checkr='time Rrel CMD check --no-vignettes'
alias checkd='time Rdev CMD check --no-vignettes'
alias bioccheck='Rdev CMD BiocCheck'

## For vim users who need different versions of R
## alias vimo='R_LIBS_USER=$HOME/R/bioc-oldrel/  RLOC=$HOME/src/svn/r-oldrel/R/bin  vim'
## alias vimr='R_LIBS_USER=$HOME/R/bioc-release/ RLOC=$HOME/src/svn/r-release/R/bin vim'
## alias vimd='R_LIBS_USER=$HOME/R/bioc-devel/   RLOC=$HOME/src/svn/r-devel/R/bin   vim'

alias locate='locate -i'
alias sudo='sudo '
alias tmux="TERM=screen-256color-bce tmux"

alias fullpath='readlink -f'
alias bump="$HOME/scripts/version_bump.sh"
alias rm='rm -i'

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
