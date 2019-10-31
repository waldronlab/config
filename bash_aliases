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

alias Rold="R_LIBS_USER=$HOME/R/bioc-oldrel $HOME/src/svn/r-oldrel/R/bin/R --no-save --no-restore-data --no-environ"
alias Rrel="R_LIBS_USER=$HOME/R/bioc-release $HOME/src/svn/r-release/R/bin/R --no-save --no-restore-data --no-environ"
alias Rdev="R_LIBS_USER=$HOME/R/bioc-devel $HOME/src/svn/r-release/R/bin/R --no-save --no-restore-data --no-environ"

alias rstudev="RSTUDIO_WHICH_R=$HOME/src/svn/r-release/R/bin/R R_LIBS_USER=$HOME/R/bioc-devel rstudio --no-save --no-restore-data --no-environ"
alias rsturel="RSTUDIO_WHICH_R=$HOME/src/svn/r-release/R/bin/R R_LIBS_USER=$HOME/R/bioc-release rstudio --no-save --no-restore-data --no-environ"
alias rdevstudio="RSTUDIO_WHICH_R=$HOME/src/svn/r-devel/R/bin/R R_LIBS_USER=$HOME/R/rdevel rstudio --no-save --no-restore-data"

alias devel="R_LIBS_USER=$HOME/R/r-devel $HOME/src/svn/r-devel/R/bin/R --no-save --no-restore-data"
alias release="R_LIBS_USER=$HOME/R/r-release $HOME/src/svn/r-release/R/bin/R --no-save --no-restore-data"
alias oldrel="R_LIBS_USER=$HOME/R/r-oldrel $HOME/src/svn/r-oldrel/R/bin/R --no-save --no-restore-data"

alias buildr='Rdev CMD build --no-build-vignettes'
alias checkr='time Rdev CMD check --no-build-vignettes'
alias review="$HOME/Bioconductor/BiocReviews/review.sh"
alias bioccheck='Rdev CMD BiocCheck'

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

