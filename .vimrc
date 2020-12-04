" Normally we use vim-extensions. If you want true vi-compatibility
" remove change the following statements
set nocompatible        " Use Vim defaults instead of 100% vi compatibility
set backspace=indent,eol,start  " more powerful backspacing

" Now we set some defaults for the editor
" We're using https://github.com/ciaranm/securemodelines instead
" set modeline            " Execute Ex, Vi and Vim modelines
set history=50          " keep 50 lines of command line history
set ruler               " show the cursor position all the time
set hlsearch            " highlight all matches of the previous search pattern
set number              " show line numbers
set visualbell t_vb=    " disable terminal beep/bell

" Suffixes that get lower priority when doing tab completion for filenames.
" These are files we are not likely to want to edit or read.
set suffixes=.bak,~,.swp,.o,.obj,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc

" Handle Doxygen comments
let g:load_doxygen_syntax = 1
autocmd Filetype c,cpp set comments^=b:///,b://!

if has('unix')
  let g:clang_library_path = glob("/usr/lib/*/libclang.so*")
  if empty(g:clang_library_path) " FreeBSD port
    let g:clang_library_path = glob("/usr/local/llvm*/*/libclang.so*")
  endif
  let g:clang_auto_user_options = '.clang_complete, compile_commands.json, path'
  let g:clang_snippets = 1
else
  " Prevent loading of the Clang plugin: it causes crashes on Windows
  let g:clang_complete_loaded = 1
endif

" Prevent CT_DEVENV's Python version from shadowing the system one
if exists('$CT_DEVENV_SYSTEM_HOME')
  let s:path_rebuild = split($PATH, ":")
  let s:python_loc = index(s:path_rebuild, $CT_DEVENV_SYSTEM_HOME . "/Build/python/python27/bin")
  if s:python_loc >= 0
    call add(s:path_rebuild, s:path_rebuild[(s:python_loc)])
    call remove(s:path_rebuild, s:python_loc)
    let $PATH = join(s:path_rebuild, ":")
  endif
endif

" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default.
syntax on

" Uncomment the following to have Vim jump to the last position when
" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif

" Uncomment the following to have Vim load indentation rules and plugins
" according to the detected filetype.
if has("autocmd")
  filetype plugin indent on
endif

" The following are commented out as they cause vim to behave a lot
" differently from regular Vi. They are highly recommended though.
set showcmd             " Show (partial) command in status line.
set showmatch           " Show matching brackets.
"set ignorecase         " Do case insensitive matching
"set smartcase          " Do smart case matching
set incsearch           " Incremental search
"set autowrite          " Automatically save before commands like :next and :make
"set hidden             " Hide buffers when they are abandoned
set mouse=nh            " Enable mouse usage (normal mode and in a help file) in terminals
set tabpagemax=150      " Allow up to 30 tabs to be opened straight from the command line

" Filetype specific scripts
if filereadable("/usr/share/vim-scripts/macros/closetag.vim")
  autocmd Filetype html,xml,xsl source /usr/share/vim-scripts/macros/closetag.vim
endif
if filereadable("/usr/share/vim-scripts/plugin/a.vim")
  autocmd Filetype c,cpp source /usr/share/vim-scripts/plugin/a.vim
endif
if filereadable("/usr/share/vim-scripts/plugin/DoxygenToolkit.vim")
  autocmd Filetype c,cpp source /usr/share/vim-scripts/plugin/DoxygenToolkit.vim
endif
autocmd Filetype c,cpp map <C-F12> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>

nnoremap <silent> <F8> :TlistToggle<CR>
let tlist_rust_settings = 'rust;m:module;c:constant;d:macro;g:enum;s:struct;u:union;t:trait;T:typedef;v:variable;f:function'

augroup filetype
  autocmd BufNewFile,BufRead *.i,*.swg set filetype=swig autoindent
  autocmd BufNewFile,BufRead *.as set filetype=actionscript

  autocmd BufNewFile,BufRead *.nw set filetype=noweb

  autocmd BufNewFile,BufRead /etc/apache2/{sites-enabled,sites-available}/* set filetype=apache
  autocmd BufNewFile,BufRead /etc/bind/named.conf.* set filetype=named

  autocmd BufRead,BufNewFile *.ll     set filetype=llvm
  autocmd BufRead,BufNewFile *.td     set filetype=tablegen
  autocmd BufRead,BufNewFile ~/Private/.watdo/tmp/*.markdown,~/.watdo/tmp/*.markdown set filetype=todo
augroup END

" Syslog stuff
autocmd BufNewFile,BufRead /var/log/{{amd,auth,console,cron,daemon,daily,debug,kerberos,kern,lpr,monthly,ppp,slip,user}.log,external/,mail.{log,info,warn,err},news/news.{crit,err,notice},debug,messages,pflog,syslog,security,maillog,lpd-errs,sendmail.st,xferlog,cron}* set filetype=messages readonly noswapfile

" TomTom coding style
autocmd BufNewFile,BufRead $HOME/[Pp]erforce/*.{cpp,hpp,c,h} setl expandtab softtabstop=2 shiftwidth=2 colorcolumn=101,161

nmap <F2> :wa<Bar>exe "mksession! " . v:this_session<CR>

" Additional help documents
if isdirectory(expand("~/.vim/doc"))
  helptags ~/.vim/doc
endif

" Highlight trailing whitespace and badly mixed TABs/spaces
let c_space_errors=1

" LaTeX stuff
let g:Tex_MultipleCompileFormats = 'dvi,pdf'
let g:Tex_DefaultTargetFormat = 'pdf'
" Allows execution of shell code when compiling a LaTeX file
" let g:Tex_CompileRule_pdf = 'pdflatex -shell-escape --interaction=nonstopmode $*'
let g:Tex_ViewRule_pdf = 'evince'
"let g:Tex_ViewRule_pdf = 'acroread'
let g:Tex_ItemStyle_inparaitem = '\item '
let g:Tex_ItemStyle_inparaenum = '\item '
let tex_no_flagderiv_teststuff = 1

let g:noweb_backend = "markdown"
let g:noweb_language = "python"

if &term =~ "^xterm"
  if has("terminfo")
    set t_Co=8
    set t_Sf=[3%p1%dm
    set t_Sb=[4%p1%dm
  else
    set t_Co=8
    set t_Sf=[3%dm
    set t_Sb=[4%dm
  endif
  set background=dark
elseif &term =~ "^screen"
  " Ensure XTerm ctrl-page(up|down) sequences are recognized even in GNU Screen and Tmux.
  map <Esc>[5;5~ <C-PageUp>
  map <Esc>[6;5~ <C-PageDown>
  set background=dark
endif

if isdirectory("/usr/share/lilypond/2.14.2/vim")
  set runtimepath+=/usr/share/lilypond/2.14.2/vim
  autocmd BufNewFile,BufRead *.ly set filetype=lilypond
endif

set secure exrc
set undofile
set undodir=~/.vim/undohist,.

if isdirectory(expand("~/Private"))
  set viminfo='100,<50,s10,h,n~/Private/.viminfo
endif

let g:pathogen_disabled = []
if has("patch-7.3.598")
  call add(g:pathogen_disabled, 'clang_complete')
else
  call add(g:pathogen_disabled, 'YouCompleteMe')
endif

if isdirectory("/usr/share/vim-youcompleteme")
  call add(g:pathogen_disabled, 'YouCompleteMe')
  set runtimepath+=/usr/share/vim-youcompleteme
endif

if executable("gpg2")
  let g:GPGExecutable = "gpg2 --trust-model always"
endif

runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()

if globpath(&runtimepath, "plugin/airline.vim") != ""
  set laststatus=2 " Always display a status line when airline provides it
  let g:airline_section_z = airline#section#create(['windowswap', '%3p%% ', 'linenr', ':%3v ', '(%3o) '])
endif

let g:solarized_termcolors=256
let g:solarized_contrast = "high"
let g:solarized_termtrans = 1
colorscheme solarized
