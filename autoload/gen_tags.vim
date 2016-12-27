" ============================================================================
" File: gen_tags.vim
" Author: Jia Sui <jsfaint@gmail.com>
" Description: This file contains some command function for other file.
" ============================================================================

"Find the root of the project
"if the project managed by git, find the git root.
"else return the current work directory.
function! gen_tags#find_project_root()
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
    let g:gen_tags#project_root = l:sub
  else
    if has('win32') || has('win64')
      let l:path=getcwd()
      let l:path=substitute(l:path, '\\', '/', 'g')
      let g:gen_tags#project_root = l:path
    else
      let g:gen_tags#project_root = getcwd()
    endif
  endif

  return g:gen_tags#project_root
endfunction

function! gen_tags#system_async(cmd, ...)
  let l:cmd = a:cmd

  if has('nvim')
    if a:0 == 0
      call jobstart(l:cmd)
    else
      call jobstart(l:cmd, {'on_exit': function('a:1')})
    endif
  elseif has('job')
    if a:0 == 0
      call job_start(l:cmd)
    else
      call job_start(l:cmd, {'close_cb': 'a:1'})
    endif
  else
    if has('unix')
      let l:cmd = l:cmd . ' &'
    else
      let l:cmd = 'cmd /c start ' . l:cmd
    endif

    call system(l:cmd)
    if a:0 != 0
      call a:1()
    endif
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
