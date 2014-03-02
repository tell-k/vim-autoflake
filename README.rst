========================
vim-autoflake
========================

vim-autoflake is a Vim plugin that applies autoflake to your current file.
autoflake remove unused imports and unused variables as reported by pyflakes. 

Required
=====================

* `autoflake <https://pypi.python.org/pypi/autoflake>`_

Installation
=====================

Simply put the contents of this repository in your ~/.vim/bundle directory.

Documentaion(Read The Docs)
==============================

* https://vim-autoflake.readthedocs.org/en/latest/

Usage
=====================

shortcut

1. Open Python file.
2. Press <F9> to run autoflake on it

call function

::

 :Autoflake

Customization
=====================

If you don't want to use the `<F9>` key for autoflake, simply remap it to
another key.  It autodetects whether it has been remapped and won't register
the `<F9>` key if so.  For example, to remap it to `<F3>` instead, use:

::

 autocmd FileType python map <buffer> <F3> :call Autoflake()<CR>

To allow autoflake to remove additional unused imports (other than than those from the standard library), use the autoflake_imports option. It accepts a comma-separated list of names.

::

 let g:autoflake_imports="django,requests,urllib3"

Remove all unused imports (whether or not they are from the standard library).

::

 let g:autoflake_remove_all_unused_imports=1

Remove unused variables, 

:: 

 let g:autoflake_remove_unused_variables=1

Disable show diff window

:: 

 let g:autoflake_disable_show_diff=1
