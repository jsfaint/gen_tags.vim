# gen_tags.vim

[![Join the chat at https://gitter.im/gen_tags-vim/Lobby](https://badges.gitter.im/gen_tags-vim/Lobby.svg)](https://gitter.im/gen_tags-vim/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

  Async plugin for [Vim](https://github.com/vim/vim)/[NeoVim](https://github.com/neovim/neovim) to ease the use of [ctags](http://ctags.io/)/[gtags](http://www.gnu.org/software/global/).</br>
  It is used for generate and maintain tags for you with multiple platform support, tested on Windows/Linux/macOS.

  `gen_tags.vim` will detect SCM(git, hg, svn) root and use it as the project root path. But you can also create a folder named as `.root` to specify a directory as the project root path.

  Generate/Update ctags and gtags will run in background.

## Difference between ctags and gtags

  GNU global(aka gtags) is more powerful than ctags, which support definition, reference, calling, called, include, string and etc, but ctags only support definition.

  As we can use GNU global why did I still support ctags in this plugin?</br>
  That's because GNU global only support 6 languages (C, C++, Yacc, Java, PHP4 and assembly) natively.</br>
  ctags can support more languages(41 showed on the website).

  Actually global can support more languages with Pygments plugin parser, for more details please refer `PLUGIN_HOWTO.pygments` in global document.

## Installation

* [dein.vim](https://github.com/shougo/dein.vim)

  Add `call dein#add('jsfaint/gen_tags.vim')` to your vimrc</br>
  Then launch `vim`/`nvim` and run `:call dein#install()`

* [vim-plug](https://github.com/junegunn/vim-plug)

  Add `Plug 'jsfaint/gen_tags.vim'` to your vimrc</br>
  Then launch `vim/nvim` and run `:PlugInstall`

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
    :ClearCtags!     Remove all files, include the db dir
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

    ```viml
    :ClearGTAGS     Remove GTAGS files
    :ClearGTAGS!    Remove all files, include the db dir
    ```

### Key Mapping

  `ctrl+]` is the default mapping support by Vim for definition

  The following mapping is set for gtags when `g:gen_tags#gtags_default_map` is 1,
which uses the `cscope` interface .

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

## Detail Usage

For more details about the usage, please refer to the help document in vim by `:help gen_tags.vim`

----

Thanks for reading :)</br>
If you like this plugin, please star it on github!

And one more thing, bug reports and pull-requests are greatly appreciated :)
