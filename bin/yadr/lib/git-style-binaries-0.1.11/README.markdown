git-style-binaries
==================

Ridiculously easy git-style binaries.

This gem uses [`trollop`](http://trollop.rubyforge.org/) for option parsing

## Installation

    gem install jashmenn-git-style-binaries --source=http://gems.github.com

## Screencast

Checkout <a href="http://www.xcombinator.com/movies/git-style-binaries.mov">the new screencast!</a>

<a href="http://www.xcombinator.com/movies/git-style-binaries.mov"><img src="http://github.com/jashmenn/git-style-binaries/tree/master/doc/gsb-screencast.png?raw=true" width='880' height='784' border=0></a>

## Try it out

    cd `gem env gemdir`/gems/jashmenn-git-style-binaries-0.1.4/test/fixtures
    ./wordpress -h
    ./wordpress help post

## Goal

Lets use the imaginary `wordpress` gem. Let's say we have three different
actions we want to specify:

* categories
* list
* post

Each command has its own binary in a directory structure like this:

    bin/
    |-- wordpress
    |-- wordpress-categories
    |-- wordpress-list
    `-- wordpress-post

The goal is to be able to call commands in this manner:

    wordpress -h          # gives help summary of all commands
    wordpress-list -h     # gives long help of wordpress-list
    wordpress list -h     # ditto
    echo "about me" | wordpress-post --title="new post"  # posts a new post with that title

## Example code
Our `bin/wordpress` binary is called the *primary* . Our primary only needs to contain the following line:

    #!/usr/bin/env ruby
    require 'git-style-binary/command'

`git-style-binary` will automatically make this command the primary. 

The `bin/wordpress-post` binary could contain the following: 

    #!/usr/bin/env ruby
    require 'git-style-binary/command'

    GitStyleBinary.command do
      short_desc "create a blog post"
      banner <<-EOS
    Usage: #{command.full_name} #{all_options_string} {content|STDIN}

    Posts content to a wordpress blog

    EOS
      opt :blog,     "short name of the blog to use", :default => 'default'
      opt :category, "tag/category. specify multiple times for multiple categories", :type => String, :multi => true
      opt :title,    "title for the post", :required => true, :type => String
      opt :type,     "type of the content [html|xhtml|text]", :default => 'html', :type => String

      run do |command|
        command.die :type, "type must be one of [html|xhtml|text]" unless command.opts[:type] =~ /^(x?html|text)$/i

        puts "Subcommand name:     #{command.name.inspect}"
        puts "Options:             #{command.opts.inspect}"
        puts "Remaining arguments: #{command.argv.inspect}"
      end
    end

And so on with the other binaries.

## Running the binaries 

Now if we run `wordpress -h` we get the following output:
     
    NAME
          wordpress

    VERSION
          0.0.1 (c) 2009 Nate Murray - local

    SYNOPSIS
          wordpress [--version] [--test-primary] [--help] [--verbose] COMMAND [ARGS]

    SUBCOMMANDS
       wordpress-categories
           do something with categories

       wordpress-help      
           get help for a specific command

       wordpress-list      
           list blog postings

       wordpress-post      
           create a blog post


      See 'wordpress help COMMAND' for more information on a specific command.

    OPTIONS
        -v, --verbose         
          verbose


        -t, --test-primary=<s>
          test an option on the primary


        -e, --version         
          Print version and exit


        -h, --help            
          Show this message



Default **options**, **version string**, and **usage banner** are automatically selected for you. 
The subcommands and their short descriptions are loaded automatically!

You can pass the `-h` flag to any one of the subcommands (with or without the
connecting `-`) or use the built-in `help` subcommand for the same effect. For instance:

    $ wordpress help post

    NAME
          wordpress-post - create a blog post

    VERSION
          0.0.1 (c) 2009 Nate Murray - local

    SYNOPSIS
          wordpress-post [--type] [--version] [--test-primary] [--blog] [--help] [--verbose] [--category]
          [--title] COMMAND [ARGS] {content|STDIN} 

    OPTIONS
        -v, --verbose         
          verbose


        -t, --test-primary=<s>
          test an option on the primary


        -b, --blog=<s>        
          short name of the blog to use (default: default)


        -c, --category=<s>    
          tag/category. specify multiple times for multiple
          categories


        -i, --title=<s>       
          title for the post


        -y, --type=<s>        
          type of the content [html|xhtml|text] (default: html)


        -e, --version         
          Print version and exit


        -h, --help            
          Show this message


For more examples, see the binaries in `test/fixtures/`.

## Primary options

Often you may *want* the primary to have its own set of options. Simply call `GitStyleBinary.primary` with a block like so:

    #!/usr/bin/env ruby
    require 'git-style-binary/command'
    GitStyleBinary.primary do
      version "#{command.full_name} 0.0.1 (c) 2009 Nate Murray - local"
      opt :test_primary, "a primary string option", :type => String

      run do |command|
        puts "Primary Options: #{command.opts.inspect}"
      end
    end

Primary options are **inherited** by all subcommands. That means in this case
all subcommands will now get the `--test-primary` option available to them as
well as this new `version` string.

## Option parsing

Option parsing is done by [trollop](http://trollop.rubyforge.org/).
`git-style-binary` uses this more-or-less exactly. See the [trollop
documentation](http://trollop.rubyforge.org/) for information on how to setup
the options and flags.

## Callbacks

Callbacks are available on the primary and subcommands. Available callbacks currently
are before/after_run. These execute before the run block of the command parser and take
take one argument, which is the command itself

## The `run` block

To get the 'introspection' on the individual binaries every binary is `load`ed
on `primary help`. We need a way to get that information while not running
every command when calling `primary help`. To achieve that you need to put what
will be run in the `run` block. 

`run` `yields` a `Command` object which contains a number of useful options
such as `name`, `full_name`, `opts`, and `argv`. 

* `command.opts` is a hash of the options parsed
* `command.argv` is an array of the remaining arguments

## Features
* automatic colorization
* automatic paging

## To Learn more

Play with the examples in the `test/fixtures` directory.

## Credits
* `git-style-binary` was written by Nate Murray `<nate@natemurray.com>`
* `trollop` was written by [William Morgan](http://trollop.rubyforge.org/) 
* Inspiration comes from Ari Lerner's [git-style-binaries](http://blog.xnot.org/2008/12/16/git-style-binaries/) for [PoolParty.rb](http://poolpartyrb.com)
* [`colorize.rb`](http://colorize.rubyforge.org) by Michal Kalbarczyk
* Automatic less paging by [Nathan Weizenbaum](http://nex-3.com/posts/73-git-style-automatic-paging-in-ruby)
* Color inspiration from [Brian Henderson](http://xcombinator.com) teaching me how to get `man git` colors using `less` on MacOSX

## TODO
* automagic tab completion - Automatic for subcommands and options for any library that uses this

## Known Bugs/Problems
* Young
* A few places of really ugly code
* A feeling that this could be done in 1/2 lines of code

## Authors
By Nate Murray and Ari Lerner

## Copyright

The MIT License

Copyright (c) 2009 Nate Murray. See LICENSE for details.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
