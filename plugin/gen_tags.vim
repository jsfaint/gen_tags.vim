" ============================================================================
" File: gen_tags.vim
" Arthur: Jia Sui <jsfaint@gmail.com>
" ============================================================================

"Initial ctags support
if !exists('g:gen_tags#ctags_bin')
  let g:gen_tags#ctags_bin = 'ctags'
endif

if executable(g:gen_tags#ctags_bin)
  if !get(g:, 'loaded_gentags#ctags', 0)
    call gen_tags#ctags#init()
  endif
else
  echomsg 'ctags not found'
  echomsg 'gen_tags.vim need ctags to generate tags'
endif

"Initial gtags support
if has('cscope') && executable('gtags')
  if !get(g:, 'loaded_gentags#gtags', 0)
    call gen_tags#gtags#init()
  endif
elseif !has('cscope')
  echomsg 'Need cscope support'
  echomsg 'gen_gtags.vim need cscope support'
elseif !executable('gtags') && !executable('gtags.exe')
  echomsg 'GNU Global not found'
  echomsg 'gen_gtags.vim need GNU Global'
endif
