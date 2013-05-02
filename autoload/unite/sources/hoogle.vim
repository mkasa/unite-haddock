function! unite#sources#hoogle#define()
  if executable('hoogle')
    return s:source
  else
    return []
  endif
endfunction

let s:source = {
      \ 'name': 'hoogle',
      \ 'is_volatile': 1,
      \ 'required_pattern_length': 1,
      \ }

function! s:source.gather_candidates(args, context)
  let l:exact = !empty(filter(copy(a:args), 'v:val ==# "exact"'))
  let l:output = unite#util#system(printf('hoogle search --link --count %d %s%s', s:max_candidates(), l:exact ? '--exact ' : '', shellescape(a:context.input)))
  if unite#util#get_last_status() == 0
    return map(split(l:output, '\n'), 's:parse(a:context.input, v:val)')
  else
    return []
  endif
endfunction

function! s:parse(input, line)
  let l:line = matchstr(a:line, '^.\+\ze -- http://')
  let l:candidate = {
        \ 'word': a:input,
        \ 'abbr': l:line,
        \ 'source': 'hoogle',
        \ 'kind': 'haddock',
        \ 'action__haddock_module': '',
        \ 'action__haddock_fragment': '',
        \ }
  let l:m = matchlist(a:line, '^\(\S\+\)\s\+\(\S\+\)\(.*\)$')
  if empty(l:m)
    return l:candidate
  endif

  let [l:mod, l:sym, l:rest] = l:m[1 : 3]
  if l:mod ==# 'package'
    return l:candidate
  else
    let l:candidate.action__haddock_module = l:mod
    let l:candidate.action__haddock_fragment = matchstr(l:rest, '#.\+$')
    return l:candidate
  endif
endfunction

function! s:max_candidates()
  return get(g:, 'unite_source_hoogle_max_candidates', 200)
endfunction
