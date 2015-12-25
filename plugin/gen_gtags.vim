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
let s:file = "GTAGS"

"Check cscope support
if !has("cscope")
  echomsg "Need cscope support"
  echomsg "gen_gtags.vim need cscope support"
  finish
endif

if !executable('gtags') && !executable('gtags.exe')
  echomsg "GNU Global not found"
  echomsg "gen_gtags.vim need GNU Global"
  finish
endif

set cscopetag
set cscopeprg=gtags-cscope

"Hotkey for cscope
nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>i :cs find i <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>

function! s:add_gtags(file)
  if filereadable(a:file)
    let l:cmd = 'silent! cs add ' . a:file
    exec l:cmd
  endif
endfunction

function! s:Add_DBs()
  let l:path = gen_tags#find_project_root()
  let l:file = l:path . '/' . s:file
  call s:add_gtags(l:file)
endfunction

"Generate GTAGS
function! s:Gtags_db_gen()
  let l:path = gen_tags#find_project_root()
  let l:file = l:path . '/' . s:file

  if filereadable(l:file)
    call UpdateGtags()
    return
  else
    let l:cmd = 'gtags -c ' . l:path
  endif

  echon "Generate " | echohl NonText | echon "GTAGS" | echohl None | echo

  "Backup cwd
  let l:bak = getcwd()
  let $GTAGSPATH = l:path
  lcd $GTAGSPATH

  if gen_tags#has_vimproc()
    call vimproc#system2(l:cmd)
  else
    call system(l:cmd)
  endif

  "Restore cwd
  let $GTAGSPATH = l:bak
  lcd $GTAGSPATH
  let $GTAGSPATH = ''

  call s:add_gtags(l:file)
  echohl Function | echo "[Done]" | echohl None
endfunction


function! s:Gtags_clear()
  let l:list = ["GTAGS", "GPATH", "GRTAGS"]

  for l:item in l:list
    if filereadable(l:item)
      call delete(l:item)
    endif
  endfor
endfunction

"Command list
command! -nargs=0 -bar GenGTAGS call s:Gtags_db_gen()
command! -nargs=0 -bar ClearGTAGS call s:Gtags_clear()

"Mapping hotkey
nmap <silent> <leader>gg :GenGTAGS<cr>

function! UpdateGtags()
  let l:path = gen_tags#find_project_root()
  let l:file = l:path . '/' . s:file

  if !filereadable(l:file)
    return
  endif

  echon "Update " | echohl NonText | echon "GTAGS" | echohl None

  let l:cmd = 'global -u'

  if gen_tags#has_vimproc()
    call vimproc#system_bg(l:cmd)
  else
    if has('unix')
      let l:cmd = l:cmd . ' &'
    else
      let l:cmd = 'cmd /c start ' . l:cmd
    endif

    call system(l:cmd)
  endif

  echon " " | echohl Function | echon "[Background]" | echohl None
endfunction
augroup gen_gtags
    au!
    au BufWritePost * call UpdateGtags()
augroup END

"Add db while startup
call s:Add_DBs()
