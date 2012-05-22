if exists("b:did_ftplugin")
  finish
endif

let b:did_ftplugin = 1 " Don't load twice in one buffer

setlocal spell
