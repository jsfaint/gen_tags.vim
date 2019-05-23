" ============================================================================
" File: gen_tags.vim
" Author: Jia Sui <jsfaint@gmail.com>
" Description: This file contains some command function for other file.
" ============================================================================

"Global variables
if !exists('g:gen_tags#verbose')
  let g:gen_tags#verbose = 0
endif

"Initial blacklist
if !exists('g:gen_tags#blacklist')
  let g:gen_tags#blacklist = []
endif

"Initial glob blacklist
if !exists('g:gen_tags#blacklist_re')
  let g:gen_tags#blacklist_re = []
endif

"Use cache dir by default
if !exists('g:gen_tags#use_cache_dir')
  let g:gen_tags#use_cache_dir = 1
endif

" Specify cache dir
if !exists('g:gen_tags#cache_dir')
    let g:gen_tags#cache_dir = '$HOME/.cache/tags_dir/'
endif

" Specify default root marker
if !exists('g:gen_tags#root_marker')
  let g:gen_tags#root_marker = '.root'
endif

" Assign root path
if !exists('g:gen_tags#root_path')
  let g:gen_tags#root_path = ''
endif

"Get scm repo info
function! gen_tags#get_scm_info() abort
  let l:scm = {'type': '', 'root': ''}

  "Supported scm repo
  let l:scm_list = [g:gen_tags#root_marker, '.git', '.hg', '.svn']

  "Detect scm type
  for l:item in l:scm_list
    let l:dir = finddir(l:item, '.;')
    if !empty(l:dir)
      let l:scm['type'] = l:item
      let l:scm['root'] = l:dir
      break
    endif
  endfor

  "Not a scm repo, return
  if empty(l:scm['type'])
    return l:scm
  endif

  "Get scm root
  let l:scm['root'] = gen_tags#fix_path(fnamemodify(l:scm['root'], ':p:h'))
  let l:scm['root'] = substitute(l:scm['root'], '/' . l:scm['type'], '', 'g')

  return l:scm
endfunction

"Find the root of the project
"if the project managed by git/hg/svn, return the repo root.
"else return the current work directory.
function! gen_tags#find_project_root() abort
  " Check assign root_path
  if !empty(glob(g:gen_tags#root_path))
    return g:gen_tags#root_path
  endif

  "If it is scm repo, use scm folder as project root
  let l:scm = gen_tags#get_scm_info()
  if !empty(l:scm['type'])
    return l:scm['root']
  endif

  return gen_tags#fix_path(getcwd())
endfunction

"Fix shellslash for windows
function! gen_tags#fix_path(path) abort
  let l:path = expand(a:path, 1)
  if has('win32')
    let l:path = substitute(l:path, '\\', '/', 'g')
  endif

  return l:path
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

"Check if current path is in blacklist
function! gen_tags#isblacklist(path) abort
  if (!exists('g:gen_tags#blacklist') || g:gen_tags#blacklist == []) &&
        \ (!exists('g:gen_tags#blacklist_re') || g:gen_tags#blacklist_re == [])
    call gen_tags#echo('blacklist not set or blacklist is null')
    return 0
  endif

  for l:dir in g:gen_tags#blacklist
    let l:dir = fnamemodify(gen_tags#fix_path(l:dir), ':p:h')
    if a:path ==# l:dir
      call gen_tags#echo('Found path ' . a:path . ' in the blacklist')
      return 1
    endif
  endfor

  let l:abs_path = fnamemodify(a:path, ':p')
  for l:re in g:gen_tags#blacklist_re
    if a:path =~ l:re
      call gen_tags#echo('Found path ' . a:path . ' to be a blacklisted pattern')
      return 1
    endif

    if l:abs_path =~ l:re
      call gen_tags#echo('Found path ' . l:abs_path . ' to be a blacklisted pattern')
      return 1
    endif
  endfor

  call gen_tags#echo('Did NOT find path ' . a:path . ' in the blacklist')
  return 0
endfunction

"Get db dir according to project type and g:gen_tags#use_cache_dir
function! gen_tags#get_db_dir() abort
  let l:scm = gen_tags#get_scm_info()

  if g:gen_tags#use_cache_dir == 0 && !empty(l:scm['type'])
    let l:tagdir = l:scm['root'] . '/' . l:scm['type'] . '/tags_dir'
  else
    let l:root = gen_tags#find_project_root()
    " If g:gen_tags#cache_dir doesn't have '/', then insert '/' when concatenating
    let l:tagdir = g:gen_tags#cache_dir . 
        \ (g:gen_tags#cache_dir[-1:] == '/' ? '' : '/') .
        \ gen_tags#get_db_name(l:root)
  endif

  return gen_tags#fix_path(l:tagdir)
endfunction

"Create db root dir and cwd db dir.
function! gen_tags#mkdir(dir) abort
  if !isdirectory(a:dir)
    call mkdir(a:dir, 'p')
  endif
endfunction

function! gen_tags#opt_converter(opt) abort
  if type(a:opt) == 1 "string
    let l:cmd = split(a:opt, '\ ')
  elseif type(a:opt) == 3 "list
    let l:cmd = a:opt
  endif

  return l:cmd
endfunction

"Check file belonging
"return:
"  1: file belongs to project
"  0: file don't belong to project
function! gen_tags#is_file_belongs(file) abort
  let l:root = gen_tags#find_project_root()
  let l:srcpath = gen_tags#fix_path(fnamemodify(a:file, ':p:h'))

  if l:srcpath =~ l:root
    call gen_tags#echo('file ' . a:file . ' belongs to ' . l:root)
    return 1
  endif

  call gen_tags#echo('file ' . a:file . ' does not belong to ' . l:root)
  return 0
endfunction
