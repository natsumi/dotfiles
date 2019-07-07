""""""""""
"VIM PLUG"
"https://github.com/junegunn/vim-plug"
""""""""""
" Automatic install of vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
" Make sure you use single quotes
" Theme Plugins
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'morhetz/gruvbox'
Plug 'nanotech/jellybeans.vim'
Plug 'altercation/vim-colors-solarized'
" Files
Plug 'ctrlpvim/ctrlp.vim'
Plug 'sjl/gundo.vim'
Plug 'rking/ag.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'scrooloose/syntastic'
" Git Plugins
Plug 'tpope/vim-fugitive'
Plug 'gregsexton/gitv'
Plug 'airblade/vim-gitgutter'
" Movement
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'wesQ3/vim-windowswap'
" Javascript
Plug 'jelera/vim-javascript-syntax'
Plug 'mxw/vim-jsx'
Plug 'elzr/vim-json'
" Rails
Plug 'mustache/vim-mustache-handlebars'
Plug 'tpope/vim-rails'
Plug 'vim-ruby/vim-ruby'
Plug 'slim-template/vim-slim'
Plug 'tpope/vim-bundler'
" Elixir Plugins
Plug 'elixir-lang/vim-elixir'
Plug 'slashmili/alchemist.vim'
Plug 'powerman/vim-plugin-AnsiEsc'
Plug 'mattreduce/vim-mix'
Plug 'fholgado/minibufexpl.vim'
" Misc
Plug 'scrooloose/nerdtree'
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'pbrisbin/vim-mkdir'
Plug 'junegunn/vim-easy-align'
Plug 'tpope/vim-endwise'
Plug 'unblevable/quick-scope'
Plug 'ervandew/supertab'
Plug 'tomtom/tcomment_vim'
Plug 'wincent/terminus'

call plug#end()
"""""""""""""""
"LOOK AND FEEL"
"""""""""""""""
syntax on "Syntax highlighting
set background=dark
colorscheme gruvbox "Colorscheme to pick

set gfn=Menlo\ for\ Powerline:h14 "Font settings for OSX
"Set font for Windows
if has("gui_running") && exists("$COMSPEC")
    set gfn=Consolas:h11
endif
"256 Color temrinal support
set t_Co=256

filetype plugin indent on "Filetype highlighting
set title "Show filename in titlebar
set showmatch  " Show matching brackets.
set mat=5  " Bracket blinking.
set ruler "Set Ruler
"Enable hybrid number mode
set relativenumber
set number "Line numbers on

set nowrap "Line wrapping off
set cursorline "Highlights current line
set scrolloff=5 "Number of lines to below cursor to start auto scroll
"set list!
set listchars=tab:▸\ ,eol:¬

"set statusline=2 "Always show the statusline
set statusline+=%{fugitive#statusline()} "Fugitive status line
set laststatus=2 "Show statusline

set foldenable " enable code folding
set foldmethod=indent "Enable code folding - za to code fold
set foldlevel=99 "Enable code folding

set bs=2 "Backspace overrides anything in INSERT mode
set ttyfast "Better scrolling
set noerrorbells "No noise

"Tab completion
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
let g:SuperTabCrMapping = 0
let g:SuperTabDefaultCompletionType = 'context'
let g:SuperTabContextDefaultCompletionType = "<c-n>"
 autocmd FileType *
     \ if &omnifunc != '' |
     \     call SuperTabChain(&omnifunc, '<c-p>') |
     \ endif
set completeopt=menuone,longest,preview

"Tab spacing
set tabstop=2
set shiftwidth=2
set expandtab "convert tabs to whitepsace
set softtabstop=2 "Make backspace go back 4 spaces

"If you want the tab settings to be based on a per file-type basis use the the following:
"autocmd FileType * set tabstop=2|set shiftwidth=2|set noexpandtab
autocmd FileType python set tabstop=4|set shiftwidth=4|set expandtab

set colorcolumn=80 "Mark colum 80

" Support for es6
autocmd BufRead,BufNewFile *.es6 setfiletype javascript
let g:jsx_ext_required = 0 " Allow JSX in normal JS files

"List of files to ignore
source ~/.vim/ignore.vim

"""""""""""""""
"KEY BINDINGS"
"""""""""""""""
let mapleader=','
"Toggle visible tab/trailing space with ,l
nmap <silent> <leader>l :set list!<CR>
"Remape keys to navigate windows use Ctrl+key
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h
"Remap keys to copy and paste using clipboard
vmap <leader>c y:call system("pbcopy", getreg("\""))<CR>
nmap <leader>v :call setreg("\"",system("pbpaste"))<CR>p
"Remap keys to go forward and back on buffer
nmap <Right> :bnext<CR>
nmap <Left> :bprev<CR>
"Open gundo
map <leader>g :GundoToggle<CR>
let g:pep8_map='<leader>8' "Pep 8 keybinding
"ag bindings
nnoremap <leader>a :Ag
"Insert a comment
map <F5> :TComment<CR>
" Start interactive EasyAlign in visual mode (e.g. vip<Enter>)
vmap <Enter> <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

"Allow using . to repeat entire maps
silent! call repeat#set("\<Plug>MyWonderfulMap", v:count)

" Index ctags from any project, including those outside Rails
map <Leader>ct :!ctags -R --exclude=*.min.js .<CR>
"""""""""""""""""""
"Misc Options
"""""""""""""""""""
set hidden

set nobackup       "no backup files
set nowritebackup  "only in case you don't want a backup file while editing
set noswapfile     "no swap files
set autoread "Automatically reload files on changes

set timeoutlen=250 "Time to wait after ESC (default causes an annoying delay)
set history=256

"Ctags options
set tags+=gems.tags

set diffopt+=vertical "Fugitive option to open diffs in vertical split
set diffopt+=iwhite " Ignore whitespace when using vimdiff

"""""""""""""""""""
" Search Options
"""""""""""""""""""
set ignorecase "Case insensitive search
set hlsearch "Highlight search terms
"disable highlighted searched terms
:nmap \q :nohlsearch<CR>
set incsearch "Highlight as term is being typed
set smartcase "Case sensitive search if theres a capital letter in search string

set shortmess=atI "Reduces prompts check :help shortmess for more info
set wildmenu "Show more than 1 item for tab completion
set wildmode=list:longest  "Tab completes up to point of ambiguity
set encoding=utf-8 "Set encoding type

let g:ag_working_path_mode="r" "AG search starts at project root

""""""""""""""""""""""
" Plugins Configurations
""""""""""""""""""""""
source ~/.vim/plugins/syntastic.vim
source ~/.vim/plugins/airline.vim
source ~/.vim/plugins/nerdtree.vim

"""""""""""""""""""""
" Functions
"""""""""""""""""""""
source ~/.vim/functions/strip-whitespace.vim
source ~/.vim/functions/vim-at.vim
source ~/.vim/functions/quickscope.vim
source ~/.vim/functions/next-close-fold.vim

" Local config
if filereadable($HOME . "/.vimrc.local")
  source ~/.vimrc.local
endif
