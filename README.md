# gen_tags.vim

## Description
A simple plugin generate ctags and gtags database for vim.

The generated ctags db will be placed under `~/.cache/tags_dir/[foldername]`<br/>
GNU Global will generate **GTAGS**, **GRTAGS** and **GPATH** under the project folder.

This plugin contains two vim scripts.

1. `gen_tags.vim`

    This is the old script which support ctags.

2. `gen_gtags.vim`

    GNU Global support, this script can be used indenpendently. Use if_cscope interface in Vim.

## Installation

### Neobundle
Add `NeoBundle 'jsfaint/gen_tags.vim'` to your vimrc  
Then launch `vim` and run `:NeobundleCheck`

To install from command line: `vim +PluginInstall +qall`

### Vundle
Add `Plugin 'jsfaint/gen_tags.vim'` to your vimrc  
then aunch `vim` and run `:PluginInstall`

To install from command line: `vim +PluginInstall +qall`

### Traditional method
Put two vim script(`gen_tags.vim`, `gen_gtags.vim`) under `plugin` directory.

## Commands
* `:GenCtags`<br/>
Generate ctags database

* `:GenGTAGS`<br/>
Generate GTAGS

* `:GenAll`<br/>
Generate ctags and gtags database

* `:EditExt`<br/>
Edit an extenstion vim script for this project, use for add third-party library ctags database

e.g.: For libpcap under `e:\src\libpcap-1.3.0` add the following content to ext.conf

```
esrclibpcap-1.3.0
```

## Key Mapping
* `<leader>ga` run `:GenAll` command
* `<leader>gg` run `:GenGTAGS` command
* `<leader>gt` run `:GenCtags` command
* `<leader>ge` run `:EditExt` command

## Hotkey
The following hotkey is set for gtags find function which use cscope interface.
```
Ctrl+\ c    Find functions calling this function
Ctrl+\ d    Find functions called by this function
Ctrl+\ e    Find this egrep pattern
Ctrl+\ f    Find this file
Ctrl+\ g    Find this definition
Ctrl+\ i    Find files #including this file
Ctrl+\ s    Find this C symbol
Ctrl+\ t    Find this text string
```
