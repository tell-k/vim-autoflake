"=========================================================
" File:        python_autoflake.vim
" Author:      tell-k <ffk2005[at]gmail.com>
" Last Change: 20-Sep-2014.
" Version:     1.0.1
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
            let autoflake_cmd=g:autoflake_cmd
        else
            let autoflake_cmd="autoflake"
        endif

        if !executable(autoflake_cmd)
            echoerr "File " . autoflake_cmd . " not found. Please install it first."
            return
        endif

        if exists("g:autoflake_imports")
            let autoflake_imports=" --imports=".g:autoflake_imports
        else
            let autoflake_imports=""
        endif

        if exists("g:autoflake_remove_all_unused_imports")
            let autoflake_remove_all_unused_imports=" --remove-all-unused-imports"
        else
            let autoflake_remove_all_unused_imports=""
        endif

        if exists("g:autoflake_remove_unused_variables")
            let autoflake_remove_unused_variables=" --remove-unused-variables"
        else
            let autoflake_remove_unused_variables=""
        endi

        let execmdline=autoflake_cmd.autoflake_imports.autoflake_remove_all_unused_imports.autoflake_remove_unused_variables
        let tmpfile = tempname()
        let tmpdiff = tempname()
        let index = 0
        try
            " current cursor
            let current_cursor = getpos(".")

            " write to temporary file
            silent execute "!cat \"" . expand('%:p') . "\" > " . tmpfile
            silent execute "!". execmdline . " --in-place " . tmpfile
            if !exists("g:autoflake_disable_show_diff")
                silent execute "!". execmdline . " \"" . expand('%:p') . "\" > " . tmpdiff
            endif

            " current buffer all delete
            silent execute "%d"
            " read temp file. and write to current buffer.
            for line in readfile(tmpfile)
                call append(index, line)
                let index = index + 1
            endfor

            " remove last linebreak.
            silent execute ":" . index . "," . index . "s/\\n$//g"
            " restore cursor
            call setpos('.', current_cursor)

            " show diff
            if !exists("g:autoflake_disable_show_diff")
             botright new autoflake
             setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
             silent execute '$read ' . tmpdiff
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
            if filewritable(tmpfile)
                call delete(tmpfile)
            endif
            if filewritable(tmpdiff)
                call delete(tmpdiff)
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
