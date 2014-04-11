" ============================================================================
" File: gen_gtags.vim
" Arthur: Jason Jia <jsfaint@gmail.com>
" Description:  1. Generate GTAGS under the project folder.
"               2. Add db when vim is open.
" Required: This script requires enable cscope support and GNU global.
" Usage:
"   1. Generate GTAGS
"   :GenGTAGS or <leader>gg
" ============================================================================
let s:file="GTAGS"

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
    exec 'silent! cs add GTAGS'
  endif
endfunction

"Generate GTAGS
function! s:gtags_db_gen(file)
  echo "Generate GTAGS"

  if filereadable(a:file)
    let l:cmd='global -u'
  else
    let l:cmd='gtags'
  endif

  if s:has_vimproc()
    call vimproc#system2(l:cmd)
  else
    call system(l:cmd)
  endif

  call s:add_gtags(a:file)

  echo "Done"
endfunction

function! s:Add_DBs()
  call s:add_gtags(s:file)
endfunction

"Check if has vimproc
function! s:has_vimproc()
  let l:has_vimproc = 0
  silent! let l:has_vimproc = vimproc#version()
  return l:has_vimproc
endfunction

"Command list
command! -nargs=0 -bar GenGTAGS call s:gtags_db_gen(s:file)

"Mapping hotkey
nmap <silent> <leader>gg :GenGTAGS<cr>

"Add db while startup
call s:Add_DBs()
