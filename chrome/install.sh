#!/bin/sh
# Fix chrome web inspector fonts to be readable.
# http://blog.dotsmart.net/2011/09/30/change-font-size-in-chrome-devtools/

# Use:
DIR="$( cd "$( dirname "$0" )" && pwd )"
ln -s -f $DIR/Custom.css $HOME/Library/Application\ Support/Google/Chrome/Default/User\ StyleSheets/Custom.css
