" Turn off vi compatibility.
set nocompatible

" Get rid of beeping sound.
set noerrorbells visualbell t_vb=
autocmd GUIEnter * set visualbell t_vb=

" Enable automatic indentation.
filetype indent plugin on

" Highlight search results
set hlsearch

" Set a different color scheme
syntax enable
colorscheme monokai
set t_Co=256 " vim-monokai now only support 256 colours in terminal.
let g:monokai_term_italic = 1
let g:monokai_gui_italic = 1

" Disable Ex-mode.
nnoremap Q <Nop>

" Remove backup and swap files.
set nobackup
set noswapfile

" Alias accidental SHIFTs.
cnoremap W<CR> w<CR>
cnoremap Q<CR> q<CR>
cnoremap X<CR> x<CR>
cnoremap Sh<CR> sh<CR>
cnoremap sH<CR> sh<CR>
cnoremap SH<CR> sh<CR>

" Line numbering.
set nu

" Show special characters
set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
set list
