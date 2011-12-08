== trollop

by William Morgan (http://masanjin.net/)

Main page: http://trollop.rubyforge.org

Release announcements and comments: http://all-thing.net/label/trollop

Documentation quickstart: See Trollop.options and then Trollop::Parser#opt.
Also see the examples at http://trollop.rubyforge.org/.

== DESCRIPTION

Trollop is a commandline option parser for Ruby that just gets out of your
way. One line of code per option is all you need to write. For that, you get a
nice automatically-generated help page, robust option parsing, command
subcompletion, and sensible defaults for everything you don't specify.

== FEATURES/PROBLEMS

- Dirt-simple usage.
- Sensible defaults. No tweaking necessary, much tweaking possible.
- Support for long options, short options, short option bundling, and
  automatic type validation and conversion.
- Support for subcommands.
- Automatic help message generation, wrapped to current screen width.
- Lots of unit tests.

== REQUIREMENTS

* A burning desire to write less code.

== INSTALL

* gem install trollop

== SYNOPSIS

  require 'trollop'
  opts = Trollop::options do
    opt :monkey, "Use monkey mode"                     # flag --monkey, default false
    opt :goat, "Use goat mode", :default => true       # flag --goat, default true
    opt :num_limbs, "Number of limbs", :default => 4   # integer --num-limbs <i>, default to 4
    opt :num_thumbs, "Number of thumbs", :type => :int # integer --num-thumbs <i>, default nil
  end

  p opts # a hash: { :monkey => false, :goat => true, :num_limbs => 4, :num_thumbs => nil }

== LICENSE

Copyright (c) 2008--2009 William Morgan. Trollop is distributed under the same
terms as Ruby.
