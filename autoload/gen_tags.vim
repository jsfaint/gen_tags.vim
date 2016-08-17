" ============================================================================
" File: gen_tags.vim
" Author: Jia Sui <jsfaint@gmail.com>
" Description: This file contains some command function for other file.
" ============================================================================

"Check if has vimproc
function! gen_tags#has_vimproc()
  let l:has_vimproc = 0
  silent! let l:has_vimproc = vimproc#version()
  return l:has_vimproc
endfunction

"Find the root of the project
"if the project managed by git, find the git root.
"else return the current work directory.
function! gen_tags#find_project_root()
  if executable('git')
    let l:git_cmd = 'git rev-parse --show-toplevel'

    "check if in git repository.
    if gen_tags#has_vimproc()
      call vimproc#system2(l:git_cmd)
      if vimproc#get_last_status() == 0
        let l:is_git = 1
      else
        let l:is_git = 0
      endif
    else
      silent let l:sub = system(l:git_cmd)
      if v:shell_error == 0
        let l:is_git = 1
      else
        let l:is_git = 0
      endif
    endif
  else
    let l:is_git = 0
  endif

  if l:is_git
    if gen_tags#has_vimproc()
      let l:sub = vimproc#system2(l:git_cmd)
      let l:sub = substitute(l:sub, '\r\|\n', '', 'g')
      return l:sub
    else
      silent let l:sub = system(l:git_cmd)
      let l:sub = substitute(l:sub, '\r\|\n', '', 'g')
      return l:sub
    endif
  else
    if has('win32') || has('win64')
      let l:path=getcwd()
      let l:path=substitute(l:path, '\\', '/', 'g')
      return l:path
    else
      return getcwd()
    endif
  endif
endfunction

function! gen_tags#system(cmd)
  let l:cmd = a:cmd

  if gen_tags#has_vimproc()
    call vimproc#system2(l:cmd)
  else
    call system(l:cmd)
  endif
endfunction

function! gen_tags#system_bg(cmd)
  let l:cmd = a:cmd

  if has('job')
    call job_start(l:cmd)
  elseif gen_tags#has_vimproc()
    call vimproc#system_bg(l:cmd)
  else
    if has('unix')
      let l:cmd = l:cmd . ' &'
    else
      let l:cmd = 'cmd /c start ' . l:cmd
    endif

    call system(l:cmd)
  endif
endfunction

" Fix shellslash for windows
function! gen_tags#fix_path_for_windows(path)
  if has('win32') || has('win64')
    let l:path = substitute(a:path, '\\', '/', 'g')
    return l:path
  else
    return a:path
  endif
endfunction
