# You need link it to ~/.zsh.after/ manually
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

test -s "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

test -s "${HOME}/.scm_breeze/scm_breeze.sh" && source "${HOME}/.scm_breeze/scm_breeze.sh"

test -s "${HOME}/.fzf.zsh" && source "${HOME}/.fzf.zsh"

test -s "$HOME/.kiex/scripts/kiex" && source "$HOME/.kiex/scripts/kiex"

test -s "${HOME}/.yadr/bin/aws_zsh_completer.sh" && source "$HOME/.yadr/bin/aws_zsh_completer.sh"

export JAVA_HOME=$(/usr/libexec/java_home -v1.8)

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="${HOME}/.sdkman"
test -s "${HOME}/.sdkman/bin/sdkman-init.sh" && source "${HOME}/.sdkman/bin/sdkman-init.sh"
