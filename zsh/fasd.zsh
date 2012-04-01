# only init if installed.
if [[ -d $HOME/.fasd ]]; then
  # Initialize fasd (https://github.com/clvv/fasd)
  eval "$(fasd --init posix-alias zsh-hook)"

  # aliases

  # jump to recently used items
  alias a='fasd -a' # any
  alias s='fasd -s' # show / search / select
  alias d='fasd -d' # directory
  alias f='fasd -f' # file
  alias z='fasd_cd -d' # cd, same functionality as j in autojump
  alias v='f -e vim' # quick opening files with vim
fi

