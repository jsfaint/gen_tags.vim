# gen_tags.vim

  This plugin aim to simple the usage of ctags and gtags for Vim.<br/>
  It is used for generate and autoload exists tags.

  This plugin contains two Vim scripts, both of the script can be use indenpendently.

  1. `gen_tags.vim`

    This is the old script which support ctags.  
    The generated ctags DB will be placed under `~/.cache/tags_dir/[foldername]`<br/>

  2. `gen_gtags.vim`

    GNU Global use gtags-cscope with if_cscope interface in Vim.  
    GNU Global will generate **GTAGS**, **GRTAGS** and **GPATH** under the project folder.

## Installation

* Neobundle

  Add `NeoBundle 'jsfaint/gen_tags.vim'` to your vimrc<br/>
  Then launch `vim` and run `:NeobundleCheck`

  To install from command line: `vim +PluginInstall +qall`

* Vundle

  Add `Plugin 'jsfaint/gen_tags.vim'` to your vimrc<br/>
  Then launch `vim` and run `:PluginInstall`

  To install from command line: `vim +PluginInstall +qall`

* Traditional method

  Put two Vim script(`gen_tags.vim`, `gen_gtags.vim`) under `plugin` directory.

## gen_tags.vim

### Commands

  * `:GenCtags` or `<leader>gt`

    Generate ctags database

  * `:GenAll` or `<leader>ga`

    Generate ctags and extend database

  * `:GenExt`

    Generate extend ctags for third-party library

  * `:EditExt` or `<leader>ge`

    Edit an extend configuration file for this project, use for add third-party library ctags database

    e.g.: For libpcap under `e:\src\libpcap-1.3.0` add the following content to `ext.conf`

    ```
    e:/src/libpcap-1.3.0
    ```

  * `:ClearTags`

    Remove exist tag files.

## gen_gtags.vim

  GTAGS support the third-party library by set an environment variable `GTAGSLIBPATH`<br/>
  But you can take a more straightforward way to do the same thing, by create a symbol link of the library

  * Linux/OS X

    ```
    ln -s /usr/include/ .
    ```

  * Windows

    ```
    mklink /J include C:\TDM-GCC-32\include
    ```

### Commands
  * `:GenGTAGS` or `<leader>gg`

    Generate GTAGS

  * `:ClearGTAGS`

    Clear GTAGS files

### Hotkey

  The following hotkey is set for GTAGS find function which use cscope interface (`if_cscope`).
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

Thanks for reading :)  
If you have any question or suggestion, please mail me <jsfaint@gmail.com>
