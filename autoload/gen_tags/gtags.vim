" ============================================================================
" File: gen_gtags.vim
" Arthur: Jia Sui <jsfaint@gmail.com>
" Description:  1. Generate GTAGS under the project folder.
"               2. Add db when vim is open.
" Required: This script requires enable cscope support and GNU global.
" Usage:
"   1. Generate GTAGS
"   :GenGTAGS or <leader>gg
"   2. Clear GTAGS
"   :ClearGTAGS
" ============================================================================

function! s:gtags_add(file) abort
  if filereadable(a:file)
    let l:cmd = 'silent! cs add ' . a:file
    exec l:cmd
  endif
endfunction

function! s:gtags_auto_load() abort
  let l:path = gen_tags#find_project_root()
  let l:file = l:path . '/' . s:file
  call s:gtags_add(l:file)
endfunction

"Generate GTAGS
function! s:gtags_db_gen() abort
  let l:path = gen_tags#find_project_root()
  let b:file = l:path . '/' . s:file

  "Check if current path in the blacklist
  if gen_tags#isblacklist(l:path)
    return
  endif

  "If gtags file exist, run update procedure.
  if filereadable(b:file)
    call s:gtags_update()
    return
  endif

  let l:cmd = 'gtags ' . l:path

  function! s:gtags_backup_cwd(path) abort
    let l:bak = getcwd()
    let $GTAGSPATH = a:path
    lcd $GTAGSPATH

    return l:bak
  endfunction

  function! s:gtags_restore_cwd(bak) abort
    "Restore cwd
    let $GTAGSPATH = a:bak
    lcd $GTAGSPATH
    let $GTAGSPATH = ''
  endfunction

  function! s:gtags_db_gen_done(...) abort
    call s:gtags_restore_cwd(b:bak)

    call s:gtags_add(b:file)
    unlet b:file
    unlet b:bak
  endfunction

  "Backup cwd
  let b:bak = s:gtags_backup_cwd(l:path)

  call gen_tags#echo('Generate GTAGS in background')
  call gen_tags#system_async(l:cmd, function('s:gtags_db_gen_done'))
endfunction

function! s:gtags_clear() abort
  let l:path = gen_tags#find_project_root()
  let l:list = ['GTAGS', 'GPATH', 'GRTAGS']

  execute 'cscope kill -1'

  for l:item in l:list
    let l:file = l:path . '/' . l:item
    if filereadable(l:file)
      call delete(l:file)
    endif
  endfor
endfunction

function! s:gtags_update() abort
  let l:path = gen_tags#find_project_root()
  let l:file = l:path . '/' . s:file

  if !filereadable(l:file)
    return
  endif

  call gen_tags#echo('Update GTAGS in background')

  let l:cmd = 'global -u'
  call gen_tags#system_async(l:cmd)
endfunction

function! s:gtags_auto_gen() abort
  " If not in scm, return
  let l:scm = gen_tags#get_scm_info()
  if empty(l:scm['type'])
    return
  endif

  " If tags exist, return
  let l:path = gen_tags#find_project_root()
  let b:file = l:path . '/' . s:file
  if filereadable(b:file)
    call s:gtags_update()
  else
    call s:gtags_db_gen()
  endif
endfunction

function! gen_tags#gtags#init() abort
  if exists('g:loaded_gentags#gtags') && g:loaded_gentags#gtags == 1
    return
  endif

  let s:file = 'GTAGS'

  "Options
  if !exists('g:gen_tags#gtags_split')
    let g:gen_tags#gtags_split = ''
  endif

  if !exists('g:gen_tags#gtags_auto_gen')
    let g:gen_tags#gtags_auto_gen = 0
  endif

  set cscopetag
  set cscopeprg=gtags-cscope

  "Hotkey for cscope
  if empty(g:gen_tags#gtags_split)
    nmap <C-\>c :cs find c <C-R>=expand('<cword>')<CR><CR>
    nmap <C-\>d :cs find d <C-R>=expand('<cword>')<CR><CR>
    nmap <C-\>e :cs find e <C-R>=expand('<cword>')<CR><CR>
    nmap <C-\>f :cs find f <C-R>=expand('<cfile>')<CR><CR>
    nmap <C-\>g :cs find g <C-R>=expand('<cword>')<CR><CR>
    nmap <C-\>i :cs find i <C-R>=expand('<cfile>')<CR><CR>
    nmap <C-\>s :cs find s <C-R>=expand('<cword>')<CR><CR>
    nmap <C-\>t :cs find t <C-R>=expand('<cword>')<CR><CR>
  elseif g:gen_tags#gtags_split ==# 'h'
    nmap <C-\>c :scs find c <C-R>=expand('<cword>')<CR><CR>
    nmap <C-\>d :scs find d <C-R>=expand('<cword>')<CR><CR>
    nmap <C-\>e :scs find e <C-R>=expand('<cword>')<CR><CR>
    nmap <C-\>f :scs find f <C-R>=expand('<cfile>')<CR><CR>
    nmap <C-\>g :scs find g <C-R>=expand('<cword>')<CR><CR>
    nmap <C-\>i :scs find i <C-R>=expand('<cfile>')<CR><CR>
    nmap <C-\>s :scs find s <C-R>=expand('<cword>')<CR><CR>
    nmap <C-\>t :scs find t <C-R>=expand('<cword>')<CR><CR>
  elseif g:gen_tags#gtags_split ==# 'v'
    nmap <C-\>c :vert scs find c <C-R>=expand('<cword>')<CR><CR>
    nmap <C-\>d :vert scs find d <C-R>=expand('<cword>')<CR><CR>
    nmap <C-\>e :vert scs find e <C-R>=expand('<cword>')<CR><CR>
    nmap <C-\>f :vert scs find f <C-R>=expand('<cfile>')<CR><CR>
    nmap <C-\>g :vert scs find g <C-R>=expand('<cword>')<CR><CR>
    nmap <C-\>i :vert scs find i <C-R>=expand('<cfile>')<CR><CR>
    nmap <C-\>s :vert scs find s <C-R>=expand('<cword>')<CR><CR>
    nmap <C-\>t :vert scs find t <C-R>=expand('<cword>')<CR><CR>
  endif

  "Command list
  command! -nargs=0 GenGTAGS call s:gtags_db_gen()
  command! -nargs=0 ClearGTAGS call s:gtags_clear()

  augroup gen_gtags
    au!
    au BufWritePost * call s:gtags_update()
    au BufWinEnter * call s:gtags_auto_load()

    if g:gen_tags#gtags_auto_gen
      au BufReadPost * call s:gtags_auto_gen()
    endif
  augroup END

  let g:loaded_gentags#gtags = 1
endfunction
