""""""""""
"VIM PLUG"
"https://github.com/junegunn/vim-plug"
""""""""""

" Automatic install of vim-plug
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall
endif

" Specify a directory for plugins
" - For Neovim:
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.local/share/nvim/plugged')
" Make sure you use single quotes

" Theme Plugins
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'morhetz/gruvbox'
Plug 'nanotech/jellybeans.vim'
Plug 'altercation/vim-colors-solarized'
Plug 'romainl/Apprentice'

" Files
" TODO Find a new syntax highlighter
" Try neomake
Plug 'editorconfig/editorconfig-vim'

" Code autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Make sure to pip install pynvim
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

" Git Plugins
Plug 'tpope/vim-fugitive'
Plug 'gregsexton/gitv' " gitk clone
Plug 'airblade/vim-gitgutter'

" Movement
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'wesQ3/vim-windowswap'

" Javascript
" Plug 'jelera/vim-javascript-syntax'
" Plug 'mxw/vim-jsx'
" Plug 'elzr/vim-json'

" Rails
" Plug 'tpope/vim-rails'
" Plug 'vim-ruby/vim-ruby'
" Plug 'slim-template/vim-slim'
" Plug 'tpope/vim-bundler'

" Elixir Plugins
Plug 'elixir-lang/vim-elixir'
Plug 'slashmili/alchemist.vim'
Plug 'powerman/vim-plugin-AnsiEsc'
Plug 'mattreduce/vim-mix'
Plug 'fholgado/minibufexpl.vim'

" Text manipulation plugins
Plug 'junegunn/vim-easy-align'
Plug 'unblevable/quick-scope'
Plug 'tomtom/tcomment_vim'
Plug 'wincent/terminus'

" Misc
Plug 'scrooloose/nerdtree'
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'pbrisbin/vim-mkdir'

if empty(glob('~/.fzf'))
  Plug '/usr/local/opt/fzf'
else
  Plug '~/.fzf'
endif
Plug 'junegunn/fzf.vim'

" Initialize plugin system
call plug#end()

"""""""""""""""
"LOOK AND FEEL"
"""""""""""""""
syntax on " Syntax highlighting
set background=dark
colorscheme apprentice " Colorscheme Theme to pick

"Font settings
"""""""""""""""
" set gfn=Menlo\ for\ Powerline:h14 " Font settings for OSX
set gfn=OperatorSSm\ Nerd\ Font:h14 " Font settings for OSX

"256 Color temrinal support
set t_Co=256

filetype plugin indent on " Filetype highlighting
set title " Show filename in titlebar
set showmatch  " Show matching brackets.
set mat=5  " Bracket blinking.
set ruler " Set Ruler
"Enable hybrid number mode
set relativenumber
set number " Line numbers on

set nowrap " Line wrapping off
set cursorline " Highlights current line
set scrolloff=5 " Number of lines to below cursor to start auto scroll
"set list!
set listchars=tab:▸\ ,eol:¬

"set statusline=2 "Always show the statusline
set statusline+=%{fugitive#statusline()} " Fugitive status line
set laststatus=2 " Show statusline

set foldenable " enable code folding
set foldmethod=indent " Enable code folding - za to code fold
set foldlevel=99 " Enable code folding

set bs=2 " Backspace overrides anything in INSERT mode
set ttyfast " Better scrolling
set noerrorbells " No noise

"Tab spacing
set tabstop=2
set shiftwidth=2
set expandtab " convert tabs to whitepsace
set softtabstop=2 " Make backspace go back 2 spaces

"If you want the tab settings to be based on a per file-type basis use the the following:
"autocmd FileType * set tabstop=2|set shiftwidth=2|set noexpandtab
autocmd FileType python set tabstop=4|set shiftwidth=4|set expandtab

set colorcolumn=80 " Mark colum 80

" Support for es6
autocmd BufRead,BufNewFile *.es6 setfiletype javascript
let g:jsx_ext_required = 0 " Allow JSX in normal JS files

"List of files to ignore
source ~/.vim/ignore.vim

" Copy to systen clipboard by default
set clipboard+=unnamedplus

"""""""""""""""
"KEYBINDINGS"
"""""""""""""""
let mapleader=','
"Toggle visible tab/trailing space with ,l
nmap <silent> <leader>l :set list!<CR>
"Remape keys to navigate windows use Ctrl+key
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h
"Remap keys to go forward and back on buffer
nmap <Right> :bnext<CR>
nmap <Left> :bprev<CR>

" ripgrep search  bindings
nnoremap <leader>r :Rg<CR>
" FZF bindings
nnoremap <C-p> :Files<CR>
nnoremap <Leader>b :Buffers<CR>
nnoremap <Leader>h :History<CR>

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

nmap ,n :NERDTreeFind<CR> " Nerdtree reveal current file

"""""""""""""""""""
" General Options
"""""""""""""""""""
set hidden " hide buffers instead of closing

set nobackup       " no backup files
set nowritebackup  " only in case you don't want a backup file while editing
set noswapfile     " no swap files
set autoread " Automatically reload files on changes

set timeoutlen=250 " Time to wait after ESC (default causes an annoying delay)
set history=256
set undolevels=99 " max undo levels
set encoding=utf-8 " Set encoding type

"Ctags options
set tags+=gems.tags

set diffopt+=vertical " Fugitive option to open diffs in vertical split
set diffopt+=iwhite " Ignore whitespace when using vimdiff

"""""""""""""""""""
" Search Options
"""""""""""""""""""
set ignorecase " Case insensitive search
set hlsearch " Highlight search terms
nmap \q :nohlsearch<CR> " Disable search highlight
set incsearch " Highlight as term is being typed
set smartcase " Case sensitive search if theres a capital letter in search string

set shortmess=atI " Reduces prompts check :help shortmess for more info
set wildmenu " Show more than 1 item for tab completion
set wildmode=list:longest  " Tab completes up to point of ambiguity

"""""""""""""""""""
" Autocomplete options
"""""""""""""""""""
" Use deoplete.
" let g:deoplete#enable_at_startup = 1

" COC Settings
"""""""""""""""""""
let g:coc_global_extensions = [
      \ 'coc-css',
      \ 'coc-elixir',
      \ 'coc-html',
      \ 'coc-json',
      \ 'coc-markdownlint',
      \ 'coc-python',
      \ 'coc-solargraph',
      \ 'coc-yaml']
" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300
set cmdheight=2 " Better display for messges

" if hidden is not set, TextEdit might fail.
set hidden

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()
" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" Or use `complete_info` if your vim support it, like:
" inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[c` and `]c` to navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" Add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Enable autocomplete for these filetypes
" autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
" autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
" autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
" autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
" autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
" autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
"
""""""""""""""""""""""
" Plugins Configurations
""""""""""""""""""""""
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
