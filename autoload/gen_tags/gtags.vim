" ============================================================================
" File: gen_gtags.vim
" Arthur: Jia Sui <jsfaint@gmail.com>
" Description:  1. Generate GTAGS under the project folder.
"               2. Add db when vim is open.
" Required: This script requires enable cscope support and GNU global.
" Usage:
"   1. Generate GTAGS
"   :GenGTAGS
"   2. Clear GTAGS
"   :ClearGTAGS
" ============================================================================

function! s:gtags_add(file) abort
  if filereadable(a:file)
    let l:cmd = 'silent! cs add ' . a:file
    exec l:cmd
    silent! doautocmd User GenTags#GtagsLoaded
  endif
endfunction

function! s:gtags_auto_load() abort
  let l:file = $GTAGSDBPATH . '/' . s:file
  call s:gtags_add(l:file)
endfunction

"Generate GTAGS
function! s:gtags_db_gen() abort
  let l:src_dir = $GTAGSROOT
  let l:db_dir = $GTAGSDBPATH

  let b:file = l:db_dir . '/' . s:file

  "Check if project root in the blacklist
  if gen_tags#isblacklist(l:src_dir)
    return
  endif

  "If gtags file exist, run update procedure.
  if filereadable(b:file)
    call s:gtags_update()
    return
  endif

  let l:cmd = [g:gen_tags#gtags_bin, l:db_dir, g:gen_tags#gtags_opts]

  function! s:gtags_db_gen_done(...) abort
    call gen_tags#statusline#clear()

    if !exists('b:file')
      return
    endif
    call s:gtags_add(b:file)
    unlet b:file
  endfunction

  call gen_tags#mkdir(l:db_dir)

  call gen_tags#echo('Generating GTAGS in background')
  call gen_tags#system_async(l:cmd, function('s:gtags_db_gen_done'))
endfunction

function! s:gtags_clear(bang) abort
  let l:db_dir = $GTAGSDBPATH
  let l:list = ['GTAGS', 'GPATH', 'GRTAGS', 'GSYMS']

  execute 'cscope kill -1'

  if empty(a:bang)
    for l:item in l:list
      let l:file = l:db_dir . '/' . l:item
      if filereadable(l:file)
        call delete(l:file)
      endif
    endfor
  else
    "Remove all files include tag folder
    let l:dir = gen_tags#get_db_dir()
    call delete(l:dir, 'rf')
  endif
endfunction

function! s:gtags_update() abort
  let l:file = $GTAGSDBPATH . '/' . s:file

  if !filereadable(l:file)
    return
  endif

  call gen_tags#echo('Update GTAGS in background')

  let l:cmd = [g:gen_tags#global_bin, '-u']
  call gen_tags#system_async(l:cmd)
endfunction

function! s:gtags_auto_gen() abort
  " If not in scm, return
  let l:scm = gen_tags#get_scm_info()
  if empty(l:scm['type'])
    return
  endif

  " If tags exist update it, otherwise generate new one.
  let l:file = $GTAGSDBPATH . '/' . s:file
  if filereadable(l:file)
    call s:gtags_update()
  else
    call s:gtags_db_gen()
  endif
endfunction

function! s:gtags_set_env() abort
  let $GTAGSROOT = gen_tags#find_project_root()
  let $GTAGSDBPATH = gen_tags#get_db_dir()
endfunction

function! gen_tags#gtags#init() abort
  if exists('g:loaded_gentags#gtags') && g:loaded_gentags#gtags == 1
    return
  endif

  let s:file = 'GTAGS'

  "Options
  if !exists('g:gen_tags#gtags_auto_gen')
    let g:gen_tags#gtags_auto_gen = 0
  endif

  if !exists('g:gen_tags#gtags_opts')
    let g:gen_tags#gtags_opts = ''
  endif

  if !exists('g:gen_tags#gtags_default_map')
    let g:gen_tags#gtags_default_map = 1
  endif

  call s:gtags_set_env()

  set cscopetag
  set cscopeprg=gtags-cscope

  "Hotkey for cscope
  if g:gen_tags#gtags_default_map == 1
    nmap <C-\>c :cs find c <C-R>=expand('<cword>')<CR><CR>
    nmap <C-\>d :cs find d <C-R>=expand('<cword>')<CR><CR>
    nmap <C-\>e :cs find e <C-R>=expand('<cword>')<CR><CR>
    nmap <C-\>f :cs find f <C-R>=expand('<cfile>')<CR><CR>
    nmap <C-\>g :cs find g <C-R>=expand('<cword>')<CR><CR>
    nmap <C-\>i :cs find i <C-R>=expand('<cfile>')<CR><CR>
    nmap <C-\>s :cs find s <C-R>=expand('<cword>')<CR><CR>
    nmap <C-\>t :cs find t <C-R>=expand('<cword>')<CR><CR>
  endif

  "Command list
  command! -nargs=0 GenGTAGS call s:gtags_db_gen()
  command! -nargs=0 -bang ClearGTAGS call s:gtags_clear('<bang>')

  augroup gen_gtags
    autocmd!
    autocmd BufWritePost * call s:gtags_update()
    autocmd BufWinEnter * call s:gtags_auto_load()

    autocmd BufReadPost * call s:gtags_set_env()

    if g:gen_tags#gtags_auto_gen
      autocmd BufReadPost * call s:gtags_auto_gen()
    endif
  augroup END

  let g:loaded_gentags#gtags = 1
endfunction
