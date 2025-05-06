# cpptags

Vim plugin that customizes **'tagfunc'** for C++ files.

## Index

+ [Motivation](#motivation)
+ [Installation](#installation)
+ [Usage](#usage)
  - [Required tag generation options](#required-tag-generation-options)
  - [New tag syntax](#new-tag-syntax)

## Motivation

The default builtin ['tagfunc'](https://vimhelp.org/options.txt.html#%27tagfunc%27) is not suitable for modern C++,
lacks support for: namespaces and classes, function and methods signatures, template parameters and specialization.

The new [ctags releases](https://docs.ctags.io/en/latest/parser-cxx.html) provide support for the above features and
more.

This [filetype plugin](https://vimhelp.org/usr_05.txt.html#add-filetype-plugin) will automatically set up a new
['tagfunc'](https://vimhelp.org/options.txt.html#%27tagfunc%27) that will profit from the new ctags fields.

## Installation

An obvious precondition is having [ctags](https://vimhelp.org/tagsrch.txt.html#tags-file-format) installed.
Is available on the most popular package managers:

+ Ubuntu:
```bash
    $ sudo apt install universal-ctags
```

+ Windows:
```cmd
    > winget install UniversalCtags.Ctags 
```

+ MacOs:
```bash
    $ brew install universal-ctags
```

This plugin can be installed using any popular plugin manager (vim-plug, Vundle, etc...) but vim plugin integration is
extremely easy in later releases ([version8.0](https://vimhelp.org/version8.txt.html#version8.0) introduced package support):

+ A [vimball](https://vimhelp.org/pi_vimball.txt.html#vimball) is distributed by [www.vim.org](www.vim.org). Installation is as easy as sourcing the vimball file:
  ```vim
  :source cpptags.vba
  ```
  so is uninstall:
  ```vim
  :RmVimball cpptags.vba
  ```

+ The github repo can be cloned direcly into the `$VIMRUNTIME/pack` directory as explained in [matchit-install](https://vimhelp.org/usr_05.txt.html#matchit-install). Though using this approach many useless files in this repo will be installed too.

+ Use [getscript](https://vimhelp.org/pi_getscript.txt.html#getscript) plugin to automatically download an update it. Update the local
  `$VIMRUNTIME/GetLatest/GetLatestVimScripts.dat` adding a line associated with this plugin.

Once installed the vim's filetype plugins must be [enabled](https://vimhelp.org/filetype.txt.html#%3Afiletype-plugin-on):
```vim
:filetype plugin on
```
is adviceable to introduce this into the [.vimrc](https://vimhelp.org/starting.txt.html#vimrc) if not there already.

## Usage

For proper operation the plugin requires:
+ set up a tag file suitable for modern C/C++ navigation.
+ learn how to prompt the `:tag` and `:tselect` commands.

### Required tag generation options

In order to profit from the new [ctags output](https://docs.ctags.io/en/latest/man/ctags.1.html) several non-default options must be used:

```bash
$ ctags --extras=+f -R --languages=c++ --langmap=c++:+.c. --c++-kinds=+pl --fields=+iaeSK --fields-c++=*
        --options=<option-file-path> -f <output-tags-file> <source-dirs>
```

The options file allows simplifying the command line by including there lenghtly parameters.
It is usual to include there options devoted to resolve preprocessor macros that [ctags](https://docs.ctags.io/en/latest/man/ctags.1.html#language-specific-options) cannot understand by itself.

Old C/C++ libraries relied heavily on preprocessor magic and require tedious composition of option files to generate a
useful ctags output. For example, the [microsoft version of the STL](https://github.com/microsoft/STL) requires the
following options:

```bash
    -D _STD_BEGIN= namespace std {
    -D _STD_END=}
    -D _STD= ::std::
    -D _CHRONO= ::std::chrono::
    -D _RANGES= ::std::ranges::
    -D _STDEXT_BEGIN= namespace stdext {
    -D _STDEXT_END=}
    -D _STDEXT= ::stdext::
    -D _CSTD=::
    -I _NODISCARD
    -I _EXPORT_STD
    -I _CRT_GUARDOVERFLOW
    -I _Out_writes_all_+
    -I _In_reads_+
    -I _CONSTEXPR20 
    -I _CONSTEXPR17
    -I __PURE_APPDOMAIN_GLOBAL
    -I _CRTDATA2_IMPORT
    -I _CRTIMP2_PURE_IMPORT
    -I __thiscall
    -I _STL_RESTORE_CLANG_WARNINGS
    -I _STL_DISABLE_CLANG_WARNINGS
```

fortunately new C/C++ libraries favor the new template capabilities and discourage preprocessor usage.
For example, [C++/WinRT](https://github.com/microsoft/cppwinrt) projection sources can be parsed completely with only
two options:
```bash
    -D WINRT_IMPL_AUTO(B)=B
    -I WINRT_EXPORT
```

Once the tag file is generated it must be appended to the ['tags'](https://vimhelp.org/options.txt.html#%27tag%27)
option which contains patterns to locate tag files. For example if the output file is in `~/mytagfiles/stl.tags`
we must do:
```vim
:set tags+=~/mytagfiles/stl.tags
```
For convenience, this can be included in the source files using a [modeline](https://vimhelp.org/options.txt.html#modeline).
For example ending the sources with:
```C++
/* vim: set tags+=~/mytagfiles/stl.tags: */
```

### New tag syntax

The syntax follows the natural semantics of C++. The basics are simple:

+ namespaces/classes. The use of qualified identifiers restricts the tag choices. For example:
  ```c++
  void f(); // case a
  namespace A {
      void f(); // case b
  namespace B {
      void f(); // case c
  }}
  ```
  Doing:
  - `:tsel f` will show all 3 cases (a,b & c). 
  - `:tsel A::f` will show 2 cases (b & c) and prioritize b. 
  - `:tsel A::B` will show only case c.

+ template syntax:
  ```c++
  template <typename A, typename B> class A; // forward declaration, case a
  template <typename A, typename B> class A {}; // declaration, case b
  template <> class A<int, double> {}; // specialization, case c
  ```
  Case a is ignore by ctags. Doing:
  - `:tsel A` or `:tsel A<>` will show case b only (specializations are ignored).
  - `:tsel A<int>` or `:tsel A<int,double>` will show case c only.

+ signature syntax:
  ```c++
  class a {}; // case a
  void a(); // declaration, case b
  void a() {} // definition, case c
  void a(int e, int f); // declaration, case d 
  void a(int e, int f) {} // definition, case e 
  ```
  Doing:
  - `:tsel a` will show all cases.
  - `:tsel a()` will show c, b, e & d. It:
    + ignores non-functions.
    + prioritizes definitions over declarations.
    + prioritizes functions without arguments.
  - `:tsel a(int)` or `:tsel a(int, int)` will show e, d because matches the signature.

+ operator syntax:
  ```c++
  struct O {
      operator int() { return 0; } // case a
      operator A::cB() { return {}; } // case b
  };
  struct P {
      operator int() { return 0; } // case c
  };
  ```
  Doing:
  - `:tsel operator int` will show case a and c
  - `:tsel O::operator int` will show case a
  - `:tsel operator cB` will show case b
  - `:tsel O::operator cB` will show case b
  - `:tsel O::operator A::cB` will show case b

All the above rules can be combined together, for example in:
```c++
namespace A {
    class B {
        template<bool> void m(int) {} // case a
        template<> void m<true>(int) {} // case b
};}
```
the command:
```vim
:tag A::B::m<true>(int)
```
will match case b which is the result of combining the rules above.
