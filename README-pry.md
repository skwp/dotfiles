### Install the gem

```bash
gem install pry
gem install pry-nav
gem install awesome_print
```

### Use pry

  * as irb: `pry`
  * as rails console: `script/console --irb=pry`
  * as a debugger: `require 'pry'; binding.pry` in your code (or just type `pry!<space>` to make vim do it)

### Pry Customizations:

 * `clear` command to clear screen
 * `sql` command to execute something (within a rails console)
 * `c` (continue) `n` (next) `s` (step) commands for debugging using pry-nav
 * all objects displayed in readable format (colorized, sorted hash keys) - via awesome_print
 * a few color modifications to make it more useable
 * type `help` to see all the commands
