function! gitgutter#fold#enable()
  call s:save_fold_state()

  call s:set_fold_levels()
  setlocal foldexpr=gitgutter#fold#level(v:lnum)
  setlocal foldmethod=expr
  setlocal foldlevel=0
  setlocal foldenable

  call gitgutter#utility#setbufvar(bufnr(''), 'folded', 1)
endfunction


function! gitgutter#fold#disable()
  call s:restore_fold_state()
  call gitgutter#utility#setbufvar(bufnr(''), 'folded', 0)
endfunction


function! gitgutter#fold#toggle()
  if s:folded()
    call gitgutter#fold#disable()
  else
    call gitgutter#fold#enable()
  endif
endfunction


function! gitgutter#fold#level(lnum)
  return gitgutter#utility#getbufvar(bufnr(''), 'fold_levels')[a:lnum]
endfunction


" A line in a hunk has a fold level of 0.
" A line within 3 lines of a hunk has a fold level of 1.
" All other lines have a fold level of 2.
function! s:set_fold_levels()
  let fold_levels = ['']

  for lnum in range(1, line('$'))
    let in_hunk = gitgutter#hunk#in_hunk(lnum)
    call add(fold_levels, (in_hunk ? 0 : 2))
  endfor

  for lnum in range(1, line('$'))
    if fold_levels[lnum] == 2
      let pre = lnum >= 3 ? lnum - 3 : 0
      let post = lnum + 3
      if index(fold_levels[pre:post], 0) != -1
        let fold_levels[lnum] = 1
      endif
    endif
  endfor

  call gitgutter#utility#setbufvar(bufnr(''), 'fold_levels', fold_levels)
endfunction


function! s:save_fold_state()
  call gitgutter#utility#setbufvar(bufnr(''), 'foldlevel', &foldlevel)
  call gitgutter#utility#setbufvar(bufnr(''), 'foldmethod', &foldmethod)
  if &foldmethod ==# 'manual'
    mkview
  endif
endfunction

function! s:restore_fold_state()
  let &foldlevel = gitgutter#utility#getbufvar(bufnr(''), 'foldlevel')
  let &foldmethod = gitgutter#utility#getbufvar(bufnr(''), 'foldmethod')
  if &foldmethod ==# 'manual'
    loadview
  else
    normal! zx
  endif
endfunction

function! s:folded()
  return gitgutter#utility#getbufvar(bufnr(''), 'folded')
endfunction

