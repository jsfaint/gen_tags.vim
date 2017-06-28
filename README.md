# gen_tags.vim

  Async plugin for [Vim](https://github.com/vim/vim)/[NeoVim](https://github.com/neovim/neovim) to ease the use of [ctags](http://ctags.sourceforge.net/)/[gtags](http://www.gnu.org/software/global/).</br>
  It is used for generate and maintain tags for you with multiple platform support, tested on Windows/Linux/macOS.

  `gen_tags.vim` will detect git root and use it as the project root path.

  Generate/Update ctags and gtags will run in background.

## Completion with gtags

  `gen_tags.vim` also provide a gtags completion source for [nvim-completion-manager](https://github.com/roxma/nvim-completion-manager)</br>
  It's optional, if you don't use ncm, just ignore it :smile:

## Difference between ctags and gtags

  GNU global(aka gtags) is more powerful than ctags, which support definition, reference, calling, called, include, string and etc, but ctags only support definition.

  As we can use GNU global why did I still support ctags in this plugin?</br>
  That's because GNU global only support 6 languages (C, C++, Yacc, Java, PHP4 and assembly) natively.</br>
  ctags can support more languages(41 showed on the website).

  Actually global can support more languages with Pygments plugin parser, for more details please refer `PLUGIN_HOWTO.pygments` in global document.

## Installation

* [Neobundle](https://github.com/shougo/neobundle.vim)

  Add `NeoBundle 'jsfaint/gen_tags.vim'` to your vimrc</br>
  Then launch `vim`/`nvim` and run `:NeobundleCheck`

* [vim-plug](https://github.com/junegunn/vim-plug)

  Add `Plug 'jsfaint/gen_tags.vim'` to your vimrc</br>
  Then launch `vim`/'nvim' and run `:PlugInstall`

* Traditional method

  Unzip the zip file under your .vim(*unix) or vimfiles(windows) directory.

## Ctags support

### Commands For Ctags

  * `:GenCtags`

    Generate ctags database

  * `:EditExt`

    Edit an extend configuration file for this project, use for add third-party library ctags database</br>
    The extend database will be generate automatically.

    e.g.: For libpcap under `e:\src\libpcap-1.3.0` add the following content to `ext.conf`

    ```bash
    e:/src/libpcap-1.3.0
    ```

  * `:ClearCtags`

    ```viml
    :ClearCtags      Remove tags files.
    :ClearCtags!     Remove tags files, ext.conf and the folder.
    ```

## Gtags support

  GTAGS support the third-party library by set an environment variable `GTAGSLIBPATH`</br>
  But you can take a more straightforward way to do the same thing, by create a symbol link of the library

  * Linux/macOS

    ```bash
    ln -s /usr/include/ .
    ```

  * Windows

    ```bash
    mklink /J include C:\TDM-GCC-32\include
    ```

### Commands For Gtags

  * `:GenGTAGS`

    Generate GTAGS

  * `:ClearGTAGS`

    Clear GTAGS files

### Key Mapping

  `ctrl+]` is the default mapping support by Vim for definition

  The following mapping is set for GTAGS find function which use cscope interface (`if_cscope`).

  ```text
  Ctrl+\ c    Find functions calling this function
  Ctrl+\ d    Find functions called by this function
  Ctrl+\ e    Find this egrep pattern
  Ctrl+\ f    Find this file
  Ctrl+\ g    Find this definition
  Ctrl+\ i    Find files #including this file
  Ctrl+\ s    Find this C symbol
  Ctrl+\ t    Find this text string
  ```

## Options

* `g:loaded_gentags#ctags`

Set to 1 if you want to disable ctags support

* `g:loaded_gentags#gtags`

Set to 1 if you want to disable gtags support

* `g:gen_tags#ctags_bin`

Set location of ctags. The default is 'ctags'

* `g:gen_tags#ctags_opts`

Set ctags options. The `-R` is set by default, so there is no need to add `-R` in `g:ctags_opts`.</br>
The default `g:ctags_opts` is '', you need to set it in your vimrc :smile:

* `g:gen_tags#gtags_split`

Set gtags find display behavior. The default `g:gtags_split` is ''.</br>
'' means don't split the display.</br>
'h' means horizontal splitting.</br>
'v' means vertical splitting.</br>

* `g:gen_tags#ctags_auto_gen`

Auto generate ctags when this variable is 1 and current file belongs to a git repo.</br>
The default `g:ctags_auto_gen` is 0

* `g:gen_tags#gtags_auto_gen`

Auto generate gtags when this variable is 1 and current file belongs to a git repo.</br>
The default `g:gtags_auto_gen` is 0

* `g:gen_tags#verbose`

Verbose mode to echo some message</br>
The default `g:gen_tags#verbose` is 0

----

Thanks for reading :)</br>
If you like this plugin, please star it on github!

And one more thing, bug reports and pull-requests are greatly appreciated :)
