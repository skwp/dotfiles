#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...
for config_file ($HOME/.yadr/zsh/*.zsh) source $config_file
source $HOME/.yadr/bin/aws_zsh_completer.sh
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh
PATH=$HOME/bin:$PATH
export PATH
export SIKULIXAPI_JAR=/Users/leon.li/workspace/sikulix/lib/sikulixapi.jar
