" ============================================================================
" File: statusline.vim
" Author: Jia Sui <jsfaint@gmail.com>
" Description: This file contains functions for statusline
" ============================================================================

function! gen_tags#statusline#set(msg) abort
  if ! get(g:, 'gen_tags#statusline', 0)
    return
  endif

  if !exists('w:statusline')
    let w:statusline = &statusline
  endif

  if get(w:, 'airline_active', 0)
    let w:airline_disabled = 1
  endif

  let b:msg = a:msg

  setlocal statusline=%#ModeMsg#gen_tags.vim%*%#Normal#\ %{b:msg}
endfunction

function! gen_tags#statusline#clear() abort
  if ! get(g:, 'gen_tags#statusline', 0)
    return
  endif

  if get(w:, 'airline_active', 0)
    let w:airline_disabled = 0
  endif

  if exists('w:statusline')
    let &statusline = w:statusline
    unlet w:statusline
  endif
endfunction
