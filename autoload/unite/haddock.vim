function! unite#haddock#ghc_pkg(args)
  let l:cwd = getcwd()
  lcd `=expand('%:p:h')`
  try
    " check stack first.
    let l:ret = unite#util#system('stack exec -- ghc-pkg -- ' . a:args)
    if unite#util#get_last_status() != 0
      " cabal-install >= 1.18 has 'sandbox' feature.
      let l:ret = unite#util#system('cabal sandbox ghc-pkg -- ' . a:args)
      if unite#util#get_last_status() != 0
        " cabal-install < 1.18 or outside the sandbox
        let l:ret = unite#util#system('ghc-pkg ' . a:args)
      endif
    endif
  finally
    lcd `=l:cwd`
  endtry
  return l:ret
endfunction
