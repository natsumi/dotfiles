function! <SID>StripTrailingWhitespaces()
    " Only strip if the b:noStripWhiteSpace variable isn't set
    if exists('b:noStripWhiteSpace')
      return
    endif

    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " Do the business:
    %s/\s\+$//e
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction

autocmd FileType emblem let b:noStripWhitespace=1 "keep whitespace for these filetypes
autocmd BufWritePre * call <SID>StripTrailingWhitespaces()

