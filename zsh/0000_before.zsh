# Load any user customizations prior to load
if [ -d $HOME/.zsh.before/ ]; then
  for config_file ($HOME/.zsh.before/*.zsh) source $config_file
fi
