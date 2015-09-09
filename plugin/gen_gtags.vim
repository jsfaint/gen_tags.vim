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

"Check if has vimproc
function! s:has_vimproc()
  let l:has_vimproc = 0
  silent! let l:has_vimproc = vimproc#version()
  return l:has_vimproc
endfunction

function! s:add_gtags(file)
  if filereadable(a:file)
    exec 'silent! cs add GTAGS'
  endif
endfunction

function! s:Add_DBs()
  call s:add_gtags(s:file)
endfunction

"Generate GTAGS
function! s:Gtags_db_gen(file)
  if filereadable(a:file)
    call UpdateGtags()
    return
  else
    let l:cmd='gtags'
  endif

  echon "Generate " | echohl NonText | echon "GTAGS" | echohl None

  if s:has_vimproc()
    call vimproc#system2(l:cmd)
  else
    call system(l:cmd)
  endif

  call s:add_gtags(a:file)

  echon " " | echohl Function | echon "[Done]" | echohl None
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
command! -nargs=0 -bar GenGTAGS call s:Gtags_db_gen(s:file)
command! -nargs=0 -bar ClearGTAGS call s:Gtags_clear()

"Mapping hotkey
nmap <silent> <leader>gg :GenGTAGS<cr>

function! UpdateGtags()
  if !filereadable(s:file)
    return
  endif

  echon "Update " | echohl NonText | echon "GTAGS" | echohl None

  let l:cmd='global -u'

  if s:has_vimproc()
    call vimproc#system_bg(l:cmd)
  else
    call system(l:cmd)
  endif

  echon " " | echohl Function | echon "[Done]" | echohl None
endfunction
au BufWritePost * call UpdateGtags()

"Add db while startup
call s:Add_DBs()
