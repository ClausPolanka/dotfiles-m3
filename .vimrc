syntax on
set number relativenumber
set termguicolors
set autoindent smartindent smarttab expandtab
set shiftwidth=2 tabstop=2
set ignorecase smartcase incsearch hlsearch
set backspace=indent,eol,start
set mouse=a
set undofile
set laststatus=2 ruler
set cursorline

" Better split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Leader shortcuts
let mapleader=" "
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>

" Softer visual appearance for whitespace characters
highlight SpecialKey ctermfg=243 guifg=#666666
highlight NonText    ctermfg=243 guifg=#666666

" Show whitespace characters
set list
set listchars=space:·,tab:→·,trail:·,extends:>,precedes:<,nbsp:␣

" Softer cursorline background (dark grey)
highlight CursorLine cterm=NONE ctermbg=237 guibg=#3a3a3a

" Use 'jk' to exit insert mode
inoremap jk <Esc>

" Optional: also allow 'kj'
inoremap kj <Esc>

set backup
set backupext=.bak
set backupdir=~/.vim/backup//
set undofile
set undodir=~/.vim/undo//
