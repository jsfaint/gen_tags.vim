" ============================================================================
" File: ctags.vim
" Arthur: Jia Sui <jsfaint@gmail.com>
" Description:  1. Generate ctags under the given folder.
"               2. Add db when vim is open.
"               3. support generate third-party project ctags
" Required: This script requires ctags.
" Usage:
"   1. Generate ctags db:
"       :GenCtags
"   2. Edit Extend project list
"       :EditExt
"   3. Clear ctags file
"       :ClearCtags
" ============================================================================

function! s:ctags_get_db_name() abort
  let l:file = gen_tags#get_db_dir() . '/' . s:ctags_db

  return l:file
endfunction

function! s:ctags_get_extend_list() abort
  let l:file = gen_tags#get_db_dir() . '/' . s:ext

  if filereadable(l:file)
    let l:list = readfile(l:file)
    return l:list
  endif

  return []
endfunction

function! s:ctags_get_extend_name(item) abort
  let l:file = gen_tags#get_db_dir() . '/' . gen_tags#get_db_name(a:item)

  return l:file
endfunction

function! s:ctags_add(file) abort
  exec 'set tags' . '+=' . a:file
  silent! doautocmd User GenTags#CtagsLoaded
endfunction

"Only add ctags db as extension database
function! s:ctags_add_ext() abort
  for l:item in s:ctags_get_extend_list()
    let l:file = s:ctags_get_extend_name(l:item)
    call s:ctags_add(l:file)
  endfor
endfunction

function! s:is_universal_ctags() abort
  if exists('s:ctags_version')
    return s:ctags_version
  endif

  let s:ctags_version = system(g:gen_tags#ctags_bin . ' --version') =~? '\<\%(Universal\) Ctags\>' ? 1 : 0

  return s:ctags_version
endfunction

"Generate ctags tags and set tags option
function! s:ctags_gen(filename, dir) abort
  "Check if current path in the blacklist
  if gen_tags#isblacklist(gen_tags#find_project_root())
    return
  endif

  "Generate tags directory
  let l:dir = gen_tags#get_db_dir()
  call gen_tags#mkdir(l:dir)

  call gen_tags#echo('Generating ctags in background')

  let l:cmd = s:ctags_cmd_pre()

  if empty(a:filename)
    let l:file = l:dir . '/' . s:ctags_db
    let l:cmd += ['-f', l:file, '-R', gen_tags#find_project_root()]
  else
    let l:file = a:filename
    let l:cmd += ['-f', l:file, '-R', a:dir]
  endif

  call gen_tags#system_async(l:cmd)

  "Search for existence tags string.
  let l:ret = stridx(&tags, l:dir)
  if l:ret == -1
    call s:ctags_add(l:file)
  endif
endfunction

function! s:ctags_auto_load() abort
  let l:file = s:ctags_get_db_name()
  if filereadable(l:file)
    call s:ctags_add(l:file)
    call s:ctags_add_ext()
  endif
endfunction

"Edit extend conf file
function! s:ctags_ext_edit() abort
  augroup gen_ctags
    autocmd BufWritePost ext.conf call s:ctags_ext_gen()
  augroup END

  let l:dir = gen_tags#get_db_dir()
  call gen_tags#mkdir(l:dir)
  let l:file = l:dir . '/' . s:ext
  exec 'split' l:file
endfunction

"Geterate extend ctags
function! s:ctags_ext_gen() abort
  for l:item in s:ctags_get_extend_list()
    let l:file = s:ctags_get_extend_name(l:item)
    call s:ctags_gen(l:file, l:item)
  endfor

  augroup gen_ctags
    autocmd! BufWritePost ext.conf
  augroup END
endfunction

"Delete exist tags file
function! s:ctags_clear(bang) abort
  if empty(a:bang) || !has('patch-7.4.1107')
    "Remove project ctags
    let l:file = s:ctags_get_db_name()
    if filereadable(l:file)
      call delete(l:file)
    endif

    "Remove extend ctags
    for l:item in s:ctags_get_extend_list()
      let l:file = s:ctags_get_extend_name(l:item)
      if filereadable(l:file)
        call delete(l:file)
        exec 'set tags-=' l:file
      endif
    endfor
  else
    "Remove all files include tag folder
    let l:dir = gen_tags#get_db_dir()
    call delete(l:dir, 'rf')
  endif
endfunction

function! s:ctags_auto_update() abort
  let l:tagfile = gen_tags#get_db_dir() . '/' . s:ctags_db

  if !filereadable(l:tagfile)
    return
  endif

  let l:file = expand('<afile>')

  "Prune tags content for saved file
  if g:gen_tags#ctags_prune
    call s:ctags_prune(l:tagfile, l:file)
  endif

  call s:ctags_update(l:file)
endfunction

function! s:ctags_auto_gen() abort
  " If not in scm, return
  let l:scm = gen_tags#get_scm_info()
  if empty(l:scm['type'])
    return
  endif

  " If tags exist, return
  let l:file = gen_tags#get_db_dir() . '/' . s:ctags_db
  if filereadable(l:file)
    return
  endif

  call s:ctags_gen('', '')
endfunction

function! gen_tags#ctags#init() abort
  if exists('g:loaded_gentags#ctags') && g:loaded_gentags#ctags == 1
    return
  endif

  let s:ctags_db = 'prj_tags'
  let s:ext = 'ext.conf'

  if !exists('g:gen_tags#ctags_opts')
    let g:gen_tags#ctags_opts = ''
  endif

  if !exists('g:gen_tags#ctags_auto_gen')
    let g:gen_tags#ctags_auto_gen = 0
  endif

  "Prune tags file before incremental update
  if !exists('g:gen_tags#ctags_prune')
    let g:gen_tags#ctags_prune = 0
  endif

  "Command list
  command! -nargs=0 GenCtags call s:ctags_gen('', '')
  command! -nargs=0 EditExt call s:ctags_ext_edit()
  command! -nargs=0 -bang ClearCtags call s:ctags_clear('<bang>')

  augroup gen_ctags
    autocmd!
    autocmd BufWritePost * call s:ctags_auto_update()
    autocmd BufWinEnter * call s:ctags_auto_load()

    if g:gen_tags#ctags_auto_gen
      autocmd BufReadPost * call s:ctags_auto_gen()
    endif
  augroup END

  let g:loaded_gentags#ctags = 1
endfunction

"Prune tagfile
function! s:ctags_prune(tagfile, file) abort
  if !filereadable(a:tagfile)
    return
  endif

  "Disable undofile
  if has('persistent-undo')
    let l:undostatus = &undofile
    set noundofile
  endif

  "Dsiable some options
  let l:event = &eventignore
  let l:fold = &foldmethod
  let l:swapfile = &swapfile

  set eventignore=FileType
  set nofoldenable
  set noswapfile

  "Open tagfile
  exec 'silent tabedit ' . a:tagfile

  "Delete specified lines
  if has('win32')
    let l:file = substitute(a:file, '\\', '\\\\', '')
    exec '%g/' . escape(l:file, ' \/') . '/d'
  else
    exec '%g/' . escape(a:file, ' /') . '/d'
  endif

  exec 'silent write'
  exec 'silent bd!'

  "Restore options
  let &eventignore = l:event
  let &foldmethod = l:fold
  let &swapfile = l:swapfile

  "Restore undofile setting
  if has('persistent-undo')
    let &undofile = l:undostatus
  endif
endfunction

function! s:ctags_update(file) abort
  let l:cmd = s:ctags_cmd_pre()

  let l:dir = gen_tags#get_db_dir()
  let l:file = l:dir . '/' . s:ctags_db

  let l:cmd += ['-u', '-f', l:file, '-a', gen_tags#find_project_root() . '/' . a:file]

  call gen_tags#system_async(l:cmd)
endfunction

function! s:ctags_cmd_pre() abort
  let l:cmd = [g:gen_tags#ctags_bin]

  "Extra flag in universal ctags, enable reference tags
  if s:is_universal_ctags()
    let l:cmd += ['--extras=+r']
  endif

  if !empty(g:gen_tags#ctags_opts)
    let l:cmd += [g:gen_tags#ctags_opts]
  endif

  return l:cmd
endfunction
