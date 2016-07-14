# set git to ignore ORIG_HEAD in auto-completion
zstyle ':completion:*:*' ignored-patterns '*ORIG_HEAD'
GIT_MERGE_AUTOEDIT=no
export GIT_MERGE_AUTOEDIT

# set zsh to ignore lines that start with '#'
setopt INTERACTIVE_COMMENTS


# function to switch jdk:
# !!! possibly use sdkman for this (http://sdkman.io/index.html)
function setjdk() {
  if [ $# -ne 0 ]; then
   removeFromPath '/System/Library/Frameworks/JavaVM.framework/Home/bin'
   if [ -n "${JAVA_HOME+x}" ]; then
    removeFromPath $JAVA_HOME
   fi
   export JAVA_HOME=`/usr/libexec/java_home -v $@`
   export PATH=$JAVA_HOME/bin:$PATH
  fi
 }
 function removeFromPath() {
  export PATH=$(echo $PATH | sed -E -e "s;:$1;;" -e "s;$1:?;;")
 }



# pyenv
# To enable shims and autocompletion add to your profile:
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi

# To use Homebrew's directories rather than ~/.pyenv add to your profile:
export PYENV_ROOT=/usr/local/opt/pyenv

# To enable auto-activation of pyenv-virtualenv add to your profile:
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

# To have prompt change when virtualenv is activated
# export PYENV_VIRTUALENV_DISABLE_PROMPT=0


# source work specific settings
if [ -e ~/.work-settings ]; then
  source ~/.work-settings
fi
