#
# Samples of what you can do in *.before.zsh files.
# You can create as many files as you like, or put everything in one.
#

# append your own plugins. the $plugins at the end includes the plugins
# defined by YADR.
plugins=(osx ruby vagrant $plugins)

# ignore plugins defined by YADR and use your own list. Notice there is no
# $plugins at the end.
plugins=(osx ruby vagrant)

# set your theme.
export ZSH_THEME="kennethreitz"

