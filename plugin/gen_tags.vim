" ============================================================================
" File: gen_tags.vim
" Arthur: Jia Sui <jsfaint@gmail.com>
" ============================================================================

"Initial ctags support
if !exists('g:gen_tags#ctags_bin')
  let g:gen_tags#ctags_bin = 'ctags'
endif

if !exists('g:gen_tags#gtags_bin')
  let g:gen_tags#gtags_bin = 'gtags'
endif

if !exists('g:gen_tags#global_bin')
  let g:gen_tags#global_bin = 'global'
endif

if !get(g:, 'loaded_gentags#ctags', 0)
  if executable(g:gen_tags#ctags_bin)
    call gen_tags#ctags#init()
  else
    echomsg 'ctags not found'
    echomsg 'gen_tags.vim need ctags to generate tags'
  endif
endif

"Initial gtags support
if !get(g:, 'loaded_gentags#gtags', 0)
  if has('cscope') && executable(g:gen_tags#gtags_bin)
    call gen_tags#gtags#init()
  elseif !has('cscope')
    echomsg 'Need cscope support'
    echomsg 'gen_gtags.vim need cscope support'
  elseif !executable(g:gen_tags#gtags_bin)
    echomsg 'GNU Global not found'
    echomsg 'gen_gtags.vim need GNU Global'
  endif
endif
