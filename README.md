#gen_tags.vim

A simple script for vim to easy to generate ctags and cscope database and auto add them when reopen the folder.<br/>
THe generated db will be placed under `~/.cache/ctags_dir/[foldername]`<br/>

##Commands
* `:GenCtags`<br/>
Generate ctags database

* `:GenCscop`<br/>
Generate cscope database

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
* `<leader>gc` run `:GenCscop` command
* `<leader>gt` run `:GenCtags` command
* `<leader>ge` run `:EditExt` command

##Hotkey
The following hotkey is set for cscope find function.
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
