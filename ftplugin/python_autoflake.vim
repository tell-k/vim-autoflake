"=========================================================
" File:        python_autoflake.vim
" Author:      tell-k <ffk2005[at]gmail.com>
" Last Change: 02-Mar-2014.
" Version:     1.0.0
" WebPage:     https://github.com/tell-k/vim-autoflake
" License:     MIT Licence
"==========================================================
" see also README.rst

" Only do this when not done yet for this buffer
if exists("b:loaded_autoflake_ftplugin")
    finish
endif
let b:loaded_autoflake_ftplugin=1

if !exists("*Autoflake()")
    function Autoflake()
        if exists("g:autoflake_cmd")
            let s:autoflake_cmd=g:autoflake_cmd
        else
            let s:autoflake_cmd="autoflake"
        endif

        if !executable(s:autoflake_cmd)
            echoerr "File " . s:autoflake_cmd . " not found. Please install it first."
            return
        endif

        if exists("g:autoflake_imports")
            let s:autoflake_imports=" --imports=".g:autoflake_imports
        else
            let s:autoflake_imports=""
        endif

        if exists("g:autoflake_remove_all_unused_imports")
            let s:autoflake_remove_all_unused_imports=" --remove-all-unused-imports"
        else
            let s:autoflake_remove_all_unused_imports=""
        endif

        if exists("g:autoflake_remove_unused_variables")
            let s:autoflake_remove_unused_variables=" --remove-unused-variables"
        else
            let s:autoflake_remove_unused_variables=""
        endif

        let s:execmdline=s:autoflake_cmd.s:autoflake_imports.s:autoflake_remove_all_unused_imports.s:autoflake_remove_unused_variables
        let s:tmpfile = tempname()
        let s:tmpdiff = tempname()
        let s:index = 0
        try
            " current cursor
            let s:current_cursor = getpos(".")

            " write to temporary file
            silent execute "!cat \"" . expand('%:p') . "\" > " . s:tmpfile
            silent execute "!". s:execmdline . " --in-place " . s:tmpfile
            if !exists("g:autoflake_disable_show_diff")
                silent execute "!". s:execmdline . " \"" . expand('%:p') . "\" > " . s:tmpdiff
            endif

            " current buffer all delete
            execute "%d"
            " read temp file. and write to current buffer.
            for line in readfile(s:tmpfile)
                call append(s:index, line)
                let s:index = s:index + 1
            endfor

            " remove last linebreak.
            silent execute ":" . s:index . "," . s:index . "s/\\n$//g"
            " restore cursor
            call setpos('.', s:current_cursor)

            " show diff
            if !exists("g:autoflake_disable_show_diff")
             botright new autoflake
             setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
             silent execute '$read ' . s:tmpdiff
             setlocal nomodifiable
             setlocal nu
             setlocal filetype=diff
            endif

            hi Green ctermfg=green
            echohl Green
            echo "Fixed with autoflake this file."
            echohl

        finally
            " file close
            if filewritable(s:tmpfile)
                call delete(s:tmpfile)
            endif
            if filewritable(s:tmpdiff)
                call delete(s:tmpdiff)
            endif
        endtry

    endfunction
endif

" Add mappings, unless the user didn't want this.
" The default mapping is registered under to <F9> by default, unless the user
" remapped it already (or a mapping exists already for <F9>)
if !exists("no_plugin_maps") && !exists("no_autoflake_maps")
    if !hasmapto('Autoflake(')
        noremap <buffer> <F9> :call Autoflake()<CR>
        command! -bar Autoflake call Autoflake() 
    endif
endif
