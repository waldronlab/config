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
alias del=/home/$USER/src/move_to_trash.sh

## set USER to your USERNAME

alias Rrel="R_LIBS_USER=/home/$USER/R/x86_64-pc-linux-gnu-library/bioc-release /home/$USER/src/svn/r-releaseR/bin/R --no-save --no-restore-data --no-environ"
alias Rdev="R_LIBS_USER=/home/$USER/R/x86_64-pc-linux-gnu-library/bioc-devel /home/$USER/src/svn/r-release/R/bin/R --no-save --no-restore-data --no-environ"
alias rstudio="R_LIBS_USER=/home/$USER/R/x86_64-pc-linux-gnu-library/bioc-devel rstudio --no-save --no-restore-data"

alias buildr='Rdev CMD build --no-build-vignettes'
alias checkr='time Rdev CMD check --no-build-vignettes'
alias bioccheck='Rdev CMD BiocCheck'

alias locate='locate -i'
alias sudo='sudo '
alias tmux="TERM=screen-256color-bce tmux"

if [ -x /usr/bin/subversion ]; then
    alias svnvimdiff="svn diff -r PREV | view -"
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f /home/$USER/src/google-cloud-sdk/path.bash.inc ]; then
  source /home/$USER/src/google-cloud-sdk/path.bash.inc
fi

# The next line enables shell command completion for gcloud.
if [ -f /home/$USER/src/google-cloud-sdk/completion.bash.inc ]; then
  source /home/$USER/src/google-cloud-sdk/completion.bash.inc
fi

