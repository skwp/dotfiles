2015-10-27
==================
  * Support for running zeus commands for rspec (`zl` and `zr`)
  * Ctrl-x and Ctrl-z to navigate the quickfix list

2014-06-01
==================
 * Change Cmd-Space to Ctrl-Space for vim autocomplete so it doesn't conflict with osx spotlight by default, and so there are no additional steps to install.

2014-02-15
==================

 * Replace Git Grep with Ag and remove unused plugins
 * Sneak: hit Space and type two letters to quickly jump somewhere
 * Added Ctrl-R, reverse history search for :commands
 * Remove ;; semicolon mapping. Messes with regular semicolon usage (find next char)
 * Change to Lightline instead of Airline [Fix #418]

Jan 5, 2013
==================

* Switch to lightline instead of airline for status bar. Works better in terminal vim and should be faster.
* Added investigate.vim (gK for docs)
* Fix homebrew installation of macvim with lua enabled, and fix deprecated homebrew install.

Dec 17, 2013
==================

* Cleanup of README to make it more palatable, focusing on the primary key bindings
* Improved integration with Ag, giving ,ag and ,af aliases
* Got rid of conque term, implemented a "send to iTerm" rspec runner (invoke with ,rs ,rl ,ss ,sl) for the rspec and spring/rspec versions.

March 29, 2013
==================

* Migrated to Vundle instead of pathogen for easier bundle management
* Added Silver Searcher for lightning fast :Gsearch
