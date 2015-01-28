### Adding your own ZSH theme

If you want to add your own zsh theme, you can place it in `~/.zsh.prompts` and it will automatically be picked up by the prompt loader.

Make sure you follow the naming convention of `prompt_[name]_setup`

```
touch ~/.zsh.prompts/prompt_mytheme_setup
```

See also the [Prezto](https://github.com/sorin-ionescu/prezto) project for more info on themes.

### Customizing ZSH with ~/.zsh.after/ and ~/.zsh.before/

If you want to customize your zsh experience, yadr provides two hooks via `~/.zsh.after/` and `~/.zsh.before/` directories.
In these directories, you can place files to customize things that load before and after other zsh customizations that come from `~/.yadr/zsh/*`


### Overriding the theme

To override the theme, you can do something like this:

```
echo "prompt yourprompt" > ~/.zsh.after/prompt.zsh
```

Next time you load your shell, this file will be read and your prompt will be the youprompt prompt. Use `prompt -l` to see the available prompts.
