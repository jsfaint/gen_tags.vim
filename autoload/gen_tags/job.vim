"Prune exit job from job list
function! s:job_prune(cmd) abort
  for l:item in s:job_list
    if a:cmd ==# l:item['cmd']
      let l:index = index(s:job_list, l:item)
      let l:job = l:item
    endif
  endfor

  "Not exist in list, return none
  if !exists('l:job')
    return 'none'
  endif

  let l:job_id = l:job['id']

  let l:status = s:job_status(l:job_id)

  "Remove from list, if job exit
  if l:status ==# 'exit'
    call remove(s:job_list, l:index)
    return 'exit'
  endif
endfunction

function! gen_tags#job#system_async(cmd, ...) abort
  let l:cmd = a:cmd

  if !exists('s:job_list')
    let s:job_list = []
  endif

  if s:job_prune(l:cmd) ==# 'run'
    call gen_tags#echo('The same job is still running')
    return
  end

  if a:0 == 0
    let l:job_id = s:job_start(l:cmd)
  else
    let l:job_id = s:job_start(l:cmd, a:1)
  endif

  "Record job info
  call add(s:job_list, {'id': l:job_id, 'cmd': l:cmd})
endfunction

function! s:job_stdout(job_id, data, ...) abort
  if type(a:data) == 1 "string
    call gen_tags#echo(a:data)
  elseif type(a:data) == 3 "list
    for l:item in a:data
      call gen_tags#echo(l:item)
    endfor
  endif
endfunction

function! s:job_exit(job_id, data, ...) abort
  call gen_tags#statusline#clear()
endfunction

function! s:job_start(cmd, ...) abort
  call gen_tags#statusline#set('Generating tags in background, please stand by...')
  call gen_tags#echo(string(a:cmd))

  if has('nvim')
    let l:job = {
          \ 'on_stdout': function('s:job_stdout'),
          \ 'on_stderr': function('s:job_stdout'),
          \ 'on_exit': function('s:job_exit'),
          \ }

    if a:0 != 0
      let l:job.on_exit = a:1
    endif

    let l:job_id = jobstart(a:cmd, l:job)
  elseif has('job')
    let l:job = {
          \ 'out_cb': function('s:job_stdout'),
          \ 'err_cb': function('s:job_stdout'),
          \ 'exit_cb': function('s:job_exit'),
          \ }

    if a:0 != 0
      let l:job.exit_cb = a:1
    endif

    let l:job_id = job_start(a:cmd, l:job)
  else
    if has('unix')
      let l:cmd = a:cmd + ['&']
    else
      let l:cmd = ['cmd', '/c', 'start'] + a:cmd
    endif

    call gen_tags#echo(system(join(l:cmd)))
    if a:0 != 0
      call a:1()
    endif

    call gen_tags#statusline#clear()

    let l:job_id = -1
  endif

  return l:job_id
endfunction

function! s:job_stop(job_id) abort
  if has('nvim')
    call jobstop(a:job_id)
  elseif has('job')
    call job_stop(a:job_id)
  endif
endfunction

function! s:job_status(job_id) abort
  let l:job_id = a:job_id

  "Check job status
  if has('nvim')
    try
      call jobpid(l:job_id)
      return 'run'
    catch
      return 'exit'
    endtry
  elseif has('job')
    if job_status(l:job_id) ==# 'dead'
      return 'exit'
    else
      return 'run'
    endif
  endif
endfunction

augroup gen_tags
  au!
  au VimLeave * call s:vim_on_exit()
augroup end

function! s:vim_on_exit() abort
  if !exists('s:job_list')
    return
  endif

  for l:item in s:job_list
    let l:job_id = l:item['id']
    let l:status = s:job_status(l:job_id)
    if l:status ==# 'run'
      call s:job_stop(l:job_id)
    endif
  endfor
endfunction
