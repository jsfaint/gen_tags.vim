" ============================================================================
" File: gen_tags.vim
" Arthur: Jason Jia <jsfaint@gmail.com>
" Description:  1. Generate ctags and cscope db under the given foler.
"               2. Add db when vim is open.
" Required: this script requires enable ctags and cscope support.
" Usage:
"   1. Generate both ctags and cscope db:
"       :GenAll or <leader>ga
"   2. Generate ctags db:
"       :GenCtags or <leader>gt
"   3. Generate cscope db:
"       :GenCscope or <leader>gc
"   4. Edit Extension script
"       :EditExt or <leader>ge
" ============================================================================

let s:dir=expand("$HOME/.cache/ctags_dir")
let s:ctags_db="prj_tags"
let s:cscope_db="cscope.out"
let s:ext="ext.conf"

"Check cscope support
if !has("cscope")
    echomsg "Need cscope support"
    echomsg "gen_tags.vim need cscope support"
    finish
endif

if !executable('ctags') && !executable('ctags.exe')
  echomsg "ctags not found"
  echomsg "gen_tags.vim need ctags to generate tags"
  finish
endif

set cscopetag

"Hotkey for cscope
nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>i :cs find i <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>

"Functions start from here
function! s:add_cscope(file)
  if filereadable(a:file)
    exec 'silent! cs add'  a:file
  endif
endfunction

function! s:add_ctags(file)
  if filereadable(a:file)
    exec 'set tags' . "+=" . a:file
  endif
endfunction

"Only add ctags db as extension database
function! s:add_ext(file)
  if filereadable(a:file)
    let l:list=readfile(a:file)
    for l:item in l:list
      let l:file=expand(s:dir . "/" . l:item . "/" . s:ctags_db)
      call s:add_ctags(l:file)
    endfor
  endif
endfunction

"Get db name, remove / : with , beacause they are not valid filename
function! s:get_db_name()
  let l:fold=substitute(getcwd(), '/', '', 'g')

  return substitute(l:fold, ':', '', 'g')
endfunction

"Create ctags root dir and cwd db dir.
function! s:make_ctags_dir()
  if !isdirectory(s:dir)
    call mkdir(s:dir, 'p')
  endif

  let l:dir=s:dir . "/" . s:get_db_name()
  if !isdirectory(l:dir)
    call mkdir(l:dir, 'p')
  endif
endfunction

"Generate ctags tags in cwd db dir.
function! s:Ctags_db_gen()
  echo "Generate ctags database"

  call s:make_ctags_dir()
  let l:dir=expand(s:dir . '/' . s:get_db_name())
  let l:cmd='ctags -f '. l:dir . '/' . s:ctags_db . ' -R ' . getcwd()

  if s:has_vimproc()
    call vimproc#system2(l:cmd)
  else
    call system(l:cmd)
  endif

  let l:file=l:dir . "/" . s:ctags_db

  "Search for existence tags string.
  let l:ret = stridx(&tags, l:dir)
  if l:ret == -1
    call s:add_ctags(l:file)
  endif

  echo "Done"
endfunction

"Generate cscope tags in cwd db dir.
function! s:Cscope_db_gen()
  echo "Generate cscope database"

  call s:make_ctags_dir()

  silent! cs kill 0
  let l:dir=expand(s:dir . '/' . s:get_db_name())
  let l:cmd='cscope -Rb -f ' . l:dir . '/' . s:cscope_db

  if s:has_vimproc()
    call vimproc#system2(l:cmd)
  else
    call system(l:cmd)
  endif

  let l:file=l:dir . "/" . s:cscope_db
  call s:add_cscope(l:file)

  echo "Done"
endfunction

function! s:Add_DBs()
  let l:file=expand(s:dir . "/" . s:get_db_name() . "/" . s:ctags_db)
  call s:add_ctags(l:file)

  let l:file=expand(s:dir . "/" . s:get_db_name() . "/" . s:cscope_db)
  call s:add_cscope(l:file)

  let l:file=expand(s:dir . "/" . s:get_db_name() . "/" . s:ext)
  call s:add_ext(l:file)
endfunction

function! s:Gen_all()
  call s:Ctags_db_gen()
  call s:Cscope_db_gen()
endfunction

function! s:Edit_ext()
  let l:dir=expand(s:dir . "/" . s:get_db_name())
  let l:file=l:dir . "/" . s:ext
  exec 'edit' l:file
endfunction

"Check if has vimproc
function! s:has_vimproc(...)
  let l:has_vimproc = 0
  silent! let l:has_vimproc = vimproc#version()
  return l:has_vimproc
endfunction

"Command list
command! -nargs=0 -bar GenCtags call s:Ctags_db_gen()
command! -nargs=0 -bar GenCscope call s:Cscope_db_gen()
command! -nargs=0 -bar GenAll call s:Gen_all()
command! -nargs=0 -bar EditExt call s:Edit_ext()

"Mapping hotkey
nmap <silent> <leader>gt :GenCtags<cr>
nmap <silent> <leader>gc :GenCscope<cr>
nmap <silent> <leader>ga :GenAll<cr>
nmap <silent> <leader>ge :EditExt<cr>

if has('win32')
  set shellslash
endif

"Add db while startup
call s:Add_DBs()
