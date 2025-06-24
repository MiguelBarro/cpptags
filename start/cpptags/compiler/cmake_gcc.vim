" Vim compiler file
" Compiler:     GNU C Compiler
 
if exists("current_compiler")
  finish
endif
let current_compiler = "cmake_gcc"

CompilerSet errorformat=%C\ %#%l\ %#\|%m,
        \%Z\ %#\|%p%.%#,
        \%E%f:%l:%c:\ %trror:%m,
        \%W%f:%l:%c:\ %tarning:%m,
        \%-G%.%#

CompilerSet makeprg=cmake
