" Keybinds

let g:mapleader = " "
" easier return to normal mode
inoremap jj <esc>
tnoremap <esc> <c-\><c-n>

" easier window navigation
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l

" easier save and quit
nnoremap <leader>w <cmd>w<cr>
nnoremap <leader>q <cmd>q<cr>

" Resize with arrows when using multiple windows
nnoremap <c-up> <cmd>resize -2<cr>
nnoremap <c-down> <cmd>resize +2<cr>
nnoremap <c-right> <cmd>vertical resize -2<cr>
nnoremap <c-left> <cmd>vertical resize +2<cr>

" Enable plugins and load plugin for the detected file type.
filetype plugin on
" Load an indent file for the detected file type.
filetype indent on
" Colorisation des fichiers
syntax on
" Indentation automatique
set autoindent
" Coloriser les resultats des recherches
set hlsearch
" Recherches se font sans respecter la casse
set ignorecase
" Recherche plus intelligente pour la casse (permet de rechercher une
" majuscule seule par exemple)
set smartcase
" Recherches sont faites de manière incrementale
set incsearch

" Affiche les numéros de ligne
set number
set relativenumber

" Surligne la ligne où est positionné le curseur
set cursorline

" Pas de tabulation dans les fichiers, tabulations de taille 4
set shiftwidth=4
set expandtab
set softtabstop=4
set tabstop=4

" Affichage de la ligne du bas :
set showcmd
set showmode
set showmatch
set wildmenu

" Affiche les espaces en fin de ligne
set list lcs=trail:§,tab:->,leadtab:->,nbsp:␣,extends:>

colorscheme habamax
hi CursorLine term=None cterm=None
hi CursorLineNr term=None cterm=None
