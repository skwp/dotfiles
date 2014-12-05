# Global aliases
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g C='| wc -l'
alias -g H='| head'
alias -g L="| less"
alias -g N="| /dev/null"
alias -g S='| sort'
alias -g G='| grep' # now you can do: ls foo G something

alias -g be='bundle exec' #shorter, or see prezto/modules/ruby

# Functions
#
# (f)ind by (n)ame
# usage: fn foo 
# to find all files containing 'foo' in the name
function fn() {
  ARGV=${@:1:-1}
  NAME=${@: -1}
  ls -Ghld $ARGV  **/*$NAME* 
}
