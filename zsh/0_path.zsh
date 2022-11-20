# path, the 0 in the filename causes this to load first

pathAppend() {
  # Only adds to the path if it's not already there
  if ! echo $PATH | egrep -q "(^|:)$1($|:)" ; then
    PATH=$PATH:$1
  fi
}

# Remove duplicate entries from PATH:
PATH=$(echo "$PATH" | awk -v RS=':' -v ORS=":" '!a[$1]++{if (NR > 1) printf ORS; printf $a[$1]}')

pathAppend "$HOME/.yadr/bin/yadr"
pathAppend "$HOME/.cargo/bin"
pathAppend "$HOME/.yadr/bin"
pathAppend "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
pathAppend "$HOME/.serverless/bin"
pathAppend "$HOME/Library/Android/sdk/platform-tools"
pathAppend "$HOME/Library/Liquibase/liquibase-4.12.0"
pathAppend "/usr/local/opt/python@3.9/bin"
pathAppend "/usr/local/opt/python@3.8/bin"
