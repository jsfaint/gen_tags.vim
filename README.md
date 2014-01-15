#gen_tags.vim

A simple script for vim to easy to generate ctags and cscope database and auto add them when reopen the folder.

##Usage


the generated db will be palced under ~/.ctags_dir/[foldername]

##Commands
* `:GenCtags`<br/>
Generate ctags database

* `:GenCscop`<br/>
Generate cscope database

* `:GenAll`<br/>
Generate ctags and cscope database

* `:EditExt`<br/>
Edit an extenstion vim script for this project, use for add third-party library ctags/cscope database

e.g.: Add libpcap databse
```
set tags+=~\.ctags_dir\esrclibpcap-1.3.0\\prj_tags
cs add ~\.ctags_dir\esrclibpcap-1.3.0\cscope.out e:\src\libpcap-1.3.0\
```

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
