" Vim compiler file
" Compiler:	Microsoft Visual C/C++
 
if exists("current_compiler")
  finish
endif
let current_compiler = "cmake_msvc"

CompilerSet errorformat=%C\ %\\{10\\\,}%m,
        \%o\ :\ %trror\ LNK%n:\ %m,
        \%E%f(%l\\\,%c):\ %trror\ :%m,
        \%E%f(%l\\\,%c):\ %trror\ C%n:%m,
        \%E%f(%l):\ %trror\ C%n:%m,
        \%E%f(%l\\\,%c):\ fatal\ %trror\ C%n:%m,
        \%E%f(%l):\ fatal\ %trror\ C%n:%m,
        \%W%f(%l\\\,%c):\ %tarning\ C%n:%m,
        \%W%f(%l):\ %tarning\ C%n:%m,
        \%I%f(%l\\\,%c):\ %tessage\ :%m,
        \%I%f(%l):\ %tessage\ :%m,
        \%-G%.%#

CompilerSet makeprg=cmake
