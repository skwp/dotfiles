The files in `vim/settings` are customizations stored on a per-plugin
basis. The main keymap is available in yadr-keymap.vim, but some of the vim
files contain key mappings as well.

If you are having unexpected behavior, wondering why a particular key works the way it does,
use: `:map [keycombo]` (e.g. `:map <C-\>`) to see what the key is mapped to. For bonus points, you can see where the mapping was set by using `:verbose map [keycombo]`.
If you omit the key combo, you'll get a list of all the maps. You can do the same thing with nmap, imap, vmap, etc.
