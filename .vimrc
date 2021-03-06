" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible             " required
filetype plugin indent on    " load filetype-specific indent files, required
syntax on                    " enable syntax processing, required

" SETTINGS --------------------------------------------------------------------

" Change key key
let mapleader=","

" Misc
set backspace=indent,eol,start "allow backspacing over everything in insert mode
set history=1000 "store lots of :cmdline history
set showcmd "show incomplete cmds down the bottom
set showmode "show current mode down the bottom
set number "show line numbers
set relativenumber " show relative line numbers
set incsearch "find the next match as we type the search
set hlsearch "highlight searches by default
set wrap "dont wrap lines
set linebreak "wrap lines at convenient points
set wildmode=list:longest,full "make cmdline tab completion similar to bash
set wildmenu "enable ctrl-n and ctrl-p to scroll thru matches
set wildignore=*.o,*.obj,*~ "stuff to ignore when tab completing
if &term =~ '256color'
  set t_Co=256
  set t_ut=
endif
set hidden " Hide buffers when not displayed
set noeb vb t_vb= "disable beep
set visualbell "flash screen on beep
set cursorline " highlight the current line
set colorcolumn=80 " Lines longer than 80 chars
set shellcmdflag=-lc " set the ! shell to be a login shell to get at functions and aliases
set showmatch " Show matching braces.
set ttyfast " Fast terminal connection
set virtualedit=block
set guioptions-=T " Removes toolbar
set guioptions-=r " Removes scroll bar
set guioptions-=L " Removes left scroll bar
set cm=blowfish2 " uses the Blowfish cipher in an improved mode

"default indent settings
set shiftwidth=2
set softtabstop=2 " number of spaces in tab when editing
set tabstop=2 " number of visual spaces per TAB
set expandtab " tabs are spaces
set autoindent
set smarttab

"folding settings
set foldmethod=indent "fold based on indent
set foldnestmax=3 "deepest fold is 3 levels
set nofoldenable "dont fold by default

"some stuff to get the mouse going in term
set mouse=a
set ttymouse=xterm2

" Unix
set encoding=utf8
set fileencoding=utf8
set fileformat=unix " file format Unix dammit
set fileformats=unix,dos " file format Unix dammit

" Spell check
set spell spelllang=en_us
map <Leader>sn :setlocal nospell<CR> " disable it

" Swap files
set directory=/tmp

" Line wrapping on by default
set wrap
"set linebreak

" Search options
set incsearch  " incremental searching on
set hlsearch   " highlight all matches
set ignorecase " Ignore case when searching
set magic      " Set magic on, for regular expressions
set smartcase

" Visual highlight
hi Visual term=reverse cterm=reverse guibg=Grey

" Listchars
set list
if (&termencoding ==# 'utf-8' || &encoding ==# 'utf-8') && version >= 700
  let &listchars = "tab:\u21e5\u00b7,trail:\u2423,extends:\u21c9,precedes:\u21c7,nbsp:\u26ad"
  let &fillchars = "vert:\u259a,fold:\u00b7"
else
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<
endif

" END SETTINGS ----------------------------------------------------------------

" MAPPINGS --------------------------------------------------------------------

" Capital W or Q annoyance
command WQ wq
command Wq wq
command W w
command Q q

" Will allow you to use :w!! to write to a file using sudo if you forgot to sudo
" vim file (it will prompt for sudo password when writing)
cmap w!! %!sudo tee > /dev/null %

" Cut Copy Paste
if has('unnamedplus')
  set clipboard=unnamedplus
else
  set clipboard=unnamed
endif
" Replace without yanking
vnoremap p "_dP

" Select all text
nmap <C-a> ggVG

" Moves line up or down
nmap <silent> <C-j> :.m+<CR>
nmap <silent> <C-k> :-m.<CR>k

" Search for the word under cursor in current dir
map <F4> :execute "vimgrep /" . expand("<cword>") . "/gj **" <Bar> cw<CR>

" Escape the highlighted search
nnoremap <esc><esc> :noh<return><esc>

" Buffer mappings
" ,. : list buffers
" ,b ,n ,g: go back/forward/last used buffer
" ,1 ,2: go to buffer 1/2 etc
nnoremap <Leader>. :ls<CR>
nnoremap <Leader>b :bprevious<cr>
nnoremap <Leader>n :bnext<cr>
nnoremap <Leader>g :e#<CR>
nnoremap <Leader>1 :1b<CR>
nnoremap <Leader>2 :2b<CR>
nnoremap <Leader>3 :3b<CR>
nnoremap <Leader>4 :4b<CR>
nnoremap <Leader>5 :5b<CR>
nnoremap <Leader>6 :6b<CR>
nnoremap <Leader>7 :7b<CR>
nnoremap <Leader>8 :8b<CR>
nnoremap <Leader>9 :9b<CR>
nnoremap <Leader>0 :10b<CR>

" Tab Navigation
nmap <C-S-tab> :tabprevious<cr>
nmap <C-tab> :tabnext<cr>
map <C-S-tab> :tabprevious<cr>
map <C-tab> :tabnext<cr>
imap <C-S-tab> <ESC>:tabprevious<cr>i
imap <C-tab> <ESC>:tabnext<cr>i
nmap <C-t> :tabnew<cr>
imap <C-t> <ESC>:tabnew<cr>

" END MAPPINGS ----------------------------------------------------------------

" COMMANDS --------------------------------------------------------------------

command Todo noautocmd vimgrep /TODO\|FIXME/j ** | cw "Look for notes
command Spaces autocmd BufWritePre * :%s/\s\+$//e " Delete all trailing whitespace

" END COMMANDS ----------------------------------------------------------------

" OS SPECIFIC ----------------------------------------------------------------

if has("gui_running")
  if has("gui_gtk2")
    set guifont=DejaVu\ Sans\ Mono\ for\ Powerline\ 10
  elseif has("gui_macvim")
    set guifont=DejaVu\ Sans\ Mono\ for\ Powerline:h11
  elseif has("gui_win32")
    set guifont=Consolas:h9
    set dir=$TEMP
  endif
endif

" END OS SPECIFIC ----------------------------------------------------------------
