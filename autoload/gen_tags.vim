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

"Check if job status
function! s:check_job(cmd) abort
  for l:item in s:job_list
    if a:cmd ==# l:item['cmd']
      let l:index = index(s:job_list, l:item)
      let l:job = l:item
    endif
  endfor

  "Not exist in list, return none
  if !exists('l:job')
    return 'none'
  endif

  let l:job_id = l:job['id']

  let l:status = s:job_status(l:job_id)

  "Remove from list, if job exit
  if s:job_status(l:job_id) ==# 'exit'
    call remove(s:job_list, l:index)
  endif
endfunction

function! gen_tags#system_async(cmd, ...) abort
  let l:cmd = a:cmd

  if !exists('s:job_list')
    let s:job_list = []
  endif

  if s:check_job(l:cmd) ==# 'run'
    call gen_tags#echo('The same job is still running')
    return
  end

  if a:0 == 0
    let l:job_id = s:job_start(l:cmd)
  else
    let l:job_id = s:job_start(l:cmd, a:1)
  endif

  "Record job info
  call add(s:job_list, {'id': l:job_id, 'cmd': l:cmd})
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

function! gen_tags#echo(str) abort
  if g:gen_tags#verbose
    echomsg a:str
  endif
endfunction

function! s:job_stdout(job_id, data, ...) abort
  call gen_tags#echo(a:data)
endfunction

function! s:job_start(cmd, ...) abort
  if has('nvim')
    let l:job = {
          \ 'on_stdout': function('s:job_stdout'),
          \ 'on_stderr': function('s:job_stdout'),
          \ }

    if a:0 != 0
      let l:job.on_exit = a:1
    endif

    let l:job_id = jobstart(a:cmd, l:job)
  elseif has('job')
    let l:job = {
          \ 'out_cb': function('s:job_stdout'),
          \ 'err_cb': function('s:job_stdout'),
          \ }

    if a:0 != 0
      let l:job.exit_cb = a:1
    endif

    let l:job_id = job_start(a:cmd, l:job)
  else
    if has('unix')
      let l:cmd = a:cmd . ' &'
    else
      let l:cmd = 'cmd /c start ' . a:cmd
    endif

    call system(l:cmd)
    if a:0 != 0
      call a:1()
    endif

    let l:job_id = -1
  endif

  return l:job_id
endfunction

function! s:job_stop(job_id) abort
  if has('nvim')
    call jobstop(a:job_id)
  elseif has('job')
    call job_stop(a:job_id)
  endif
endfunction

function! s:job_status(job_id) abort
  let l:job_id = a:job_id

  "Check job status
  if has('nvim')
    try
      call jobpid(l:job_id)
      return 'run'
    catch
      return 'exit'
    endtry
  elseif has('job')
    if job_status(l:job_id) ==# 'dead'
      return 'exit'
    else
      return 'run'
    endif
  endif
endfunction

augroup gen_tags
  au!
  au VimLeave * call s:vim_on_exit()
augroup end

function! s:vim_on_exit() abort
  if !exists('s:job_list')
    return
  endif

  for l:item in s:job_list
    let l:job_id = l:item['id']
    let l:status = s:job_status(l:job_id)
    if l:status ==# 'run'
      call s:job_stop(l:job_id)
    endif
  endfor
endfunction
