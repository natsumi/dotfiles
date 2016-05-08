map <C-n> :NERDTreeToggle<CR> "Activate with Ctrl-N
" Quit vim if the only buffer left is NerdTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

