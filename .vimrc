"Use Vim settings, rather then Vi settings (much better!).
"This must be first, because it changes other options as a side effect.
set nocompatible

"activate pathogen
execute pathogen#infect()
syntax on
filetype plugin indent on

" SETTINGS --------------------------------------------------------------------

" Theme
colorscheme solarized
set background=dark

" Change key key
let mapleader=","

" Misc
set backspace=indent,eol,start "allow backspacing over everything in insert mode
set history=1000 "store lots of :cmdline history
set showcmd "show incomplete cmds down the bottom
set showmode "show current mode down the bottom
set number "show line numbers
set incsearch "find the next match as we type the search
set hlsearch "highlight searches by default
set wrap "dont wrap lines
set linebreak "wrap lines at convenient points
set wildmode=list:longest,full "make cmdline tab completion similar to bash
set wildmenu "enable ctrl-n and ctrl-p to scroll thru matches
set wildignore=*.o,*.obj,*~ "stuff to ignore when tab completing
if &term =~ '256color'
  set t_ut=
endif
set hidden " Hide buffers when not displayed
set noeb vb t_vb= "disable beep
set visualbell "flash screen on beep
set cursorline " Highlight the current line
set colorcolumn=80 " Lines longer than 80 chars
set shellcmdflag=-lc " set the ! shell to be a login shell to get at functions and aliases
set showmatch " Show matching braces.
set ttyfast " Fast terminal connection
set virtualedit=block

"default indent settings
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab
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

" Will allow you to use :w!! to write to a file using sudo if you forgot to sudo
" vim file (it will prompt for sudo password when writing)
cmap w!! %!sudo tee > /dev/null %

" Cut Copy Paste
if has('unnamedplus')
  set clipboard=unnamedplus
else
  set clipboard=unnamed
endif
vnoremap p "_dP  " Replace without yanking

" Select all text
nmap <C-a> ggVG

" Moves line up or down
nmap <silent> <C-j> :.m+<CR>
nmap <silent> <C-k> :-m.<CR>k

" Search for the word under cursor in current dir
map <F4> :execute "vimgrep /" . expand("<cword>") . "/gj **" <Bar> cw<CR>

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

" END MAPPINGS ----------------------------------------------------------------

" PLUGINS ---------------------------------------------------------------------
" UltiSnips
let g:UltiSnipsSnippetDirectories=["vim-snippets/snippets"]

" Airline
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts=1

" Ruby
imap <S-CR> <CR><CR>end<Esc>-cc
let g:rubycomplete_buffer_loading = 1
let g:rubycomplete_classes_in_global = 1
let g:rubycomplete_rails = 1

" NERDTree {
" Autostart
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
" Close if it's the only window
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

noremap <leader>l :NERDTreeFind<CR><C-w>w
noremap <C-E><C-E> :NERDTree<CR>
noremap <C-E><C-C> :NERDTreeClose<CR>
let g:NERDTreeShowBookmarks = 1
let g:NERDTreeShowHidden = 1
let g:NERDTreeMouseMode = 2
let g:NERDTreeChDirMode = 2
let g:nerdtree_tabs_open_on_gui_startup = 0
let g:nerdtree_tabs_open_on_console_startup = 0
let g:nerdtree_tabs_smart_startup_focus = 1
let g:nerdtree_tabs_synchronize_view = 1
let g:nerdtree_tabs_meaningful_tab_names = 1
let g:NERDSpaceDelims = 1
"}

" Tasklist {
let g:tlWindowPosition = 1 " Open window at the bottom (use 0 for top)
" }

" ACK
"let g:ackprg="ack-grep -H --nocolor --nogroup --column"
" Minibuffer Explorer Settings
let g:miniBufExplMapWindowNavVim = 0
let g:miniBufExplMapWindowNavArrows = 0
let g:miniBufExplMapCTabSwitchBufs = 1
let g:miniBufExplMapCTabSwitchWindows = 1
let g:miniBufExplUseSingleClick = 1
let g:miniBufExplModSelTarget = 1

" END PLUGINS -----------------------------------------------------------------

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

" Tab Navigation
nmap <C-S-tab> :tabprevious<cr>
nmap <C-tab> :tabnext<cr>
map <C-S-tab> :tabprevious<cr>
map <C-tab> :tabnext<cr>
imap <C-S-tab> <ESC>:tabprevious<cr>i
imap <C-tab> <ESC>:tabnext<cr>i
nmap <C-t> :tabnew<cr>
imap <C-t> <ESC>:tabnew<cr>

" END OS SPECIFIC ----------------------------------------------------------------

" FUNCTIONS -------------------------------------------------------------------

" END FUNCTIONS ---------------------------------------------------------------
