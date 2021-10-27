#!/bin/bash

#' To be used after a Bioconductor release
#'
#' Use `git remote -v` to check if you have the correct origin and upstream
#' remotes 
#'
#' If NOT, use
#      `git remote add upstream git@git.bioconductor.org:packages/PACKAGE`
#' If your origin is not GitHub, use
#'     `git remote origin set-url git@github.com:USER/PACKAGE`
#'
#' param RELEASE the release branch name e.g., RELEASE_3_14
#'
#' usage:
#' cd PACKAGE
#' ./update_release.sh RELEASE_3_14
RELEASE=$1

git fetch --all
git pull upstream master
git push origin master
git checkout -b $RELEASE upstream/$RELEASE
git push origin $RELEASE
git checkout master
