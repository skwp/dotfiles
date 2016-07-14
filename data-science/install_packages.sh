#!/bin/sh

set -e 
set -x

brew update

# gcc for R and python
brew install gcc

# R
brew tap homebrew/science
brew install R
brew cask install rstudio

# Python
brew install python python3 pyenv pyenv-virtualenv

# use pip-compile to figure out the correct order of dependencies
pip install --upgrade pip
pip install pip-tools 

echo "numpy\npandas\nmatplotlib\njupyter\ngrip" > requirements.in
pip-compile requirements.in

pip install -r requirements.txt


# TODO figure it out for Python3
# pip3 install pip-tools 
# 
# echo "numpy\npandas\nmatplotlib\njupyter\ngrip" > requirements.in
# pip-compile requirements.in
# 
# pip3 install -r requirements.txt



# Spark
brew cask install java

brew install scala sbt apache-spark

brew install awscli s3cmd



# Utils:

# coreutiles for gdate (to simulate on Mac the behavior of Linux `date` using `gdate`)
brew install coreutils

# to work with json on the cli
brew install jq