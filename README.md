# vim-maven-plugin
This plugin provides convenient functions to Apache Maven project.

## Main features:
1. Detects your editing file if it is under Maven's project(by looking for pom.xml)
1. Executes Maven as compiler with supporting of quickfix
1. Jump files between source/test code
1. Functions for retrieving maven path in current editing buffer

## Installation:

### [VimPlugin](https://github.com/junegunn/vim-plug)(Recommended)
Put following configuration to your vim-plug block of vimrc:

```vim
Plug 'mikelue/vim-maven-plugin'
```

Execute `:PlugInstall`

### [Vundle](https://github.com/VundleVim/Vundle.vim)
Put following configuration to your vundle block of vimrc:

```vim
Plugin 'mikelue/vim-maven-plugin'
```

Execute `:PluginInstall`

### Manually
Get the source and copy the source into your runtime path of VIM.
Then type "helptags ~/vimfiles/doc/" to build tags of help file.

Use "help maven.txt" to open the help of this plugin.

## Limitations:
* **This plugin wouldn't read the content of "pom.xml" to setup the context of Maven project.
So you should setup directories of source code in your project by default.**
