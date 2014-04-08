#gen_tags.vim

A simple plugin for vim to easy to generate ctags and cscope/gtags database and auto add them when reopen the folder.<br/>
The generated db will be placed under `~/.cache/tags_dir/[foldername]`<br/>

GNU Global will generate **GTAGS**, **GRTAGS** and **GPATH** under the project folder.

**WARNING**: cscope and gtags are conflicted, you can enable cscope and disable gtags by add `let g:gen_tags#cscope_enabled=1` to your vimrc file

This plugin contains two vim scripts.

1. `gen_tags.vim`

    This is the old script which support ctags and cscope.

2. `gen_gtags.vim`

    GNU Global support, this script can be used indenpendently.

##Commands
* `:GenCtags`<br/>
Generate ctags database

* `:GenCscope`<br/>
Generate cscope database

* `:GenGTAGS`<br/>
Generate GTAGS

* `:GenAll`<br/>
Generate ctags and cscope database

* `:EditExt`<br/>
Edit an extenstion vim script for this project, use for add third-party library ctags database

e.g.: For libpcap under `e:\src\libpcap-1.3.0` add the following content to ext.conf

```
esrclibpcap-1.3.0
```

##Key Mapping
* `<leader>ga` run `:GenAll` command
* `<leader>gg` run `:GenGTAGS` command
* `<leader>gt` run `:GenCtags` command
* `<leader>gc` run `:GenCscope` command
* `<leader>ge` run `:EditExt` command

##Hotkey
The following hotkey is set for cscope/gtags-cscope find function.
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
