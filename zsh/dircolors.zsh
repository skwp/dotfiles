eval $(dircolors $HOME/.dircolors)
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
