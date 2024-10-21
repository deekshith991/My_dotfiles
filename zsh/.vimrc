" General settings
set number                " Show line numbers
set relativenumber         " Relative line numbers
set tabstop=4              " Number of spaces for a tab
set shiftwidth=4           " Number of spaces for indentation
set expandtab              " Convert tabs to spaces
set autoindent             " Automatically indent new lines
set smartindent            " Smarter autoindentation
set cursorline             " Highlight the current line
set background=dark        " Use a dark background for better visibility
set termguicolors          " Enable true color support
syntax on                  " Enable syntax highlighting
set encoding=utf-8         " Use UTF-8 encoding

" Searching
set hlsearch               " Highlight search results
set incsearch              " Incremental search
set ignorecase             " Ignore case while searching
set smartcase              " Case-sensitive search if uppercase letters are used

" Filetype detection and indentation
filetype plugin indent on  " Enable filetype-specific plugins and indentation

" Enable mouse support (optional)
set mouse=a                " Enable mouse in all modes

" Enable folding (useful for large files)
set foldmethod=syntax      " Fold based on syntax
set foldlevelstart=99      " Don't fold by default

" Auto-completion
set completeopt=menuone,noinsert,noselect
set shortmess+=c

" Specific settings for HTML, CSS, JavaScript, and Java
autocmd FileType html setlocal shiftwidth=2 tabstop=2
autocmd FileType css setlocal shiftwidth=2 tabstop=2
autocmd FileType javascript setlocal shiftwidth=2 tabstop=2
autocmd FileType java setlocal shiftwidth=4 tabstop=4

" Basic key mappings
nnoremap <C-n> :cnext<CR>  " Go to the next error or warning
nnoremap <C-p> :cprev<CR>  " Go to the previous error or warning

" Auto reload file if changed outside of Vim
set autoread

" Status line
set laststatus=2
set statusline=%f\ %y\ %m\ %r\ %=%-14.(%l,%c%V%)\ %P

