if get(s:, 'loaded', 0)
  finish
endif
let s:loaded = 1

let g:ncm2_gtags#proc = yarp#py3('ncm2_gtags')

let g:ncm2_gtags#source = get(g:, 'ncm2_gtags#source', {
      \ 'name': 'gtags',
      \ 'priority': 6,
      \ 'mark': 'gtags',
      \ 'word_pattern': '[\w/]+',
      \ 'on_complete': 'ncm2_gtags#on_complete',
      \ 'on_warmup': 'ncm2_gtags#on_warmup'
      \ })

let g:ncm2_gtags#source = extend(g:ncm2_gtags#source,
      \ get(g:, 'ncm2_gtags#source_override', {}),
      \ 'force')

func! ncm2_gtags#init() abort
  call ncm2#register_source(g:ncm2_gtags#source)
endfunc

func! ncm2_gtags#on_warmup(ctx) abort
  call g:ncm2_gtags#proc.jobstart()
endfunc

func! ncm2_gtags#on_complete(ctx) abort
  call g:ncm2_gtags#proc.try_notify('on_complete', a:ctx)
endfunc
