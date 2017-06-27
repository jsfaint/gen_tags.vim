" ============================================================================
" File: gen_tags.vim
" Author: Jia Sui <jsfaint@gmail.com>
" Description: This file contains some command function for other file.
" ============================================================================

"GLobal variables
if !exists('g:gen_tags#verbose')
  let g:gen_tags#verbose = 0
endif

function! gen_tags#git_root() abort
  if executable('git')
    let l:git_cmd = 'git rev-parse --show-toplevel'

    "check if in git repository.
    silent let l:sub = system(l:git_cmd)
    if v:shell_error == 0
      let l:is_git = 1
    else
      let l:is_git = 0
    endif
  else
    let l:is_git = 0
  endif

  if l:is_git
    silent let l:sub = system(l:git_cmd)
    let l:sub = substitute(l:sub, '\r\|\n', '', 'g')
    return l:sub
  endif

  return ''
endfunction

"Find the root of the project
"if the project managed by git, find the git root.
"else return the current work directory.
function! gen_tags#find_project_root() abort
  if exists('s:project_root')
    return s:project_root
  endif

  let s:project_root = gen_tags#git_root()
  if empty(s:project_root)
    if has('win32') || has('win64')
      let l:path=getcwd()
      let l:path=substitute(l:path, '\\', '/', 'g')
      let s:project_root = l:path
    else
      let s:project_root = getcwd()
    endif
  endif

  return s:project_root
endfunction

function! gen_tags#system_async(cmd, ...) abort
  let l:cmd = a:cmd

  if a:0 != 0
    let s:cb = a:1
  endif

  function! s:wrap(...) abort
    if exists('s:cb')
      call s:cb()
      unlet s:cb
    endif
  endfunction

  if has('nvim')
    call jobstart(l:cmd, {'on_exit': function('s:wrap')})
  elseif has('job')
    call job_start(l:cmd, {'close_cb': function('s:wrap')})
  else
    if has('unix')
      let l:cmd = l:cmd . ' &'
    else
      let l:cmd = 'cmd /c start ' . l:cmd
    endif

    call system(l:cmd)
    call s:wrap()
  endif
endfunction

"Fix shellslash for windows
function! gen_tags#fix_path_for_windows(path) abort
  if has('win32') || has('win64')
    let l:path = substitute(a:path, '\\', '/', 'g')
    return l:path
  else
    return a:path
  endif
endfunction

"Get db name, remove / : with , beacause they are not valid filename
function! gen_tags#get_db_name(path) abort
  let l:fold = substitute(a:path, '/\|\\\|\ \|:\|\.', '', 'g')
  return l:fold
endfunction
