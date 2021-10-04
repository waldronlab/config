#!/bin/bash

## see also
## https://github.com/Jiefei-Wang/Painless-R-compilation-and-installation-on-Ubuntu

## install dependencies
apt-get build-dep r-base r-base-core
apt-get install
apt-get install make subversion ccache build-essential libreadline-dev \
gfortran xorg-dev libbz2-dev liblzma-dev libpcre2-dev \
libcurl4 libcurl4-openssl-dev libblas-dev libtirpc-dev

