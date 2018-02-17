#!/bin/sh

set -e
set -x

brew update

# Spark
brew cask install java

brew install scala sbt apache-spark

brew install awscli s3cmd

# Utils

# coreutiles for gdate (to simulate on Mac the behavior of Linux `date` using `gdate`)
brew install coreutils

# to work with json on the cli
brew install jq


# install anaconda: https://www.continuum.io/downloads#macos
# move .bash_profile commands to zsh config to activate installation

# install R and python with anaconda - because it's easier

conda install -c r r-essentials
conda update -c r r-essentials

conda install -c r rstudio
conda install -c r/label/borked rstudio

# symlink R version to /usr/local/bin/R to have Rstudio find it
ln -s /Users/cindylamm/anaconda3/bin/R /usr/local/bin/R


# install jupyter

# install the package
conda install -c conda-forge jupyter_contrib_nbextensions

# install the js and css files from the package to jupyter
jupyter contrib nbextension install --user

# enable extension server configurator (to have UI)
jupyter nbextensions_configurator enable --user

