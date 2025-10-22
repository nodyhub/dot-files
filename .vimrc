" filepath: /Users/jan/git/dot-files/.vimrc
" Coloring - optimized for High Contrast Dark Tango Theme
syntax enable
syntax on
set background=dark

" Color scheme optimization for Tango
if has('termguicolors')
  set termguicolors
endif

" Try to use a colorscheme that works well with Tango if available
try
  colorscheme PaperColor
catch /^Vim\%((\a\+)\)\=:E185/
  " Fallback to default with some Tango-friendly adjustments
endtry

" Highlight current line - adjusted for High Contrast Dark Tango theme
set cursorline
hi CursorLine ctermbg=236 guibg=#2a2a2a cterm=NONE gui=NONE
hi CursorLineNr ctermfg=226 guifg=#ffff00 cterm=bold gui=bold


" Search Option
set incsearch
set hlsearch
set ignorecase

set title
set noautoindent
set ruler
set shortmess=aoOTI
set showmode
set splitbelow
set splitright
set laststatus=2
set nomodeline
set showcmd
set showmatch
set tabstop=3
set shiftwidth=3
set expandtab
set cinoptions=(0,m1,:1
set formatoptions=tcqr2
set laststatus=2
set nomodeline
set clipboard=unnamed,unnamedplus
set softtabstop=3
set showtabline=1
set smartcase
set ignorecase
set sidescroll=2
set scrolloff=4
set ttyfast
set history=10000
set hidden
set number
set backspace=indent,eol,start
set ttimeoutlen=100
set completeopt=noinsert,menuone,noselect " Modifies the auto-complete menu to behave more like an IDE.
set mouse= " Disable mouse in Vim to allow terminal selection
set wildmenu " Show a more advance menu



" Tabbing
set expandtab     " Use only space
set tabstop=2     " Width of tabstop
set shiftwidth=2  " Indent width

" Backspace Problem-Workarround
set backspace=indent,eol,start

" Disable default status line
set noshowmode

" Store last cursor position
if has("autocmd")
   au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

" Cursorline {{{
" Only show cursorline in the current window and in normal mode.
augroup cline
    au!
    au WinLeave,InsertEnter * set nocursorline
    au WinEnter,InsertLeave * set cursorline
augroup END
" }}}

" Autocompletion rebind {{{
if has("gui_running")
    " C-Space seems to work under gVim on both Linux and win32
    inoremap <C-Space> <C-n>
else " no gui
  if has("unix")
    inoremap <Nul> <C-n>
  else
  " I have no idea of the name of Ctrl-Space elsewhere
  endif
endif
" }}}


" Backups {{{
set backup                        " enable backups
set noswapfile                    " it's 2013, Vim.
set undodir=~/.vim/tmp/undo//     " undo files
set backupdir=~/.vim/tmp/backup// " backups
set directory=~/.vim/tmp/swap//   " swap files
" Make those folders automatically if they don't already exist.
if !isdirectory(expand(&undodir))
    call mkdir(expand(&undodir), "p")
endif
if !isdirectory(expand(&backupdir))
    call mkdir(expand(&backupdir), "p")
endif
if !isdirectory(expand(&directory))
    call mkdir(expand(&directory), "p")
endif
" }}}

" UTF-8 encoding within files
set encoding=utf-8
set termencoding=utf-8

" Custom syntax highlighting for High Contrast Dark Tango theme
hi Normal ctermfg=255 ctermbg=NONE guifg=#ffffff guibg=NONE
hi Comment ctermfg=240 guifg=#585858
hi Constant ctermfg=226 guifg=#ffff00
hi Statement ctermfg=51 guifg=#00ffff gui=NONE
hi Identifier ctermfg=208 guifg=#ff8700
hi PreProc ctermfg=201 guifg=#ff00ff
hi Type ctermfg=46 guifg=#00ff00 gui=NONE
hi Special ctermfg=196 guifg=#ff0000
hi Search ctermbg=226 ctermfg=16 guibg=#ffff00 guifg=#000000
hi MatchParen ctermbg=51 ctermfg=16 guibg=#00ffff guifg=#000000
hi Visual ctermbg=51 ctermfg=16 guibg=#00ffff guifg=#000000
hi LineNr ctermfg=240 ctermbg=NONE guifg=#585858 guibg=NONE
hi StatusLine ctermfg=16 ctermbg=226 guifg=#000000 guibg=#ffff00
hi StatusLineNC ctermfg=255 ctermbg=238 guifg=#ffffff guibg=#444444

" Tabbing between multiple windows
map <F7> :bp<CR>
map <F8> :bn<CR>

" Dark theme optimizations with high contrast
if &background == 'dark'
  " Fix Vim's popup menu colors to be more readable in dark themes
  hi Pmenu ctermbg=238 ctermfg=255 guibg=#444444 guifg=#ffffff
  hi PmenuSel ctermbg=51 ctermfg=16 guibg=#00ffff guifg=#000000
  hi PmenuSbar ctermbg=238 guibg=#444444
  hi PmenuThumb ctermbg=240 guibg=#585858
  
  " Fix diff colors for dark theme with high contrast
  hi DiffAdd ctermbg=22 ctermfg=46 guibg=#005f00 guifg=#00ff00
  hi DiffChange ctermbg=58 ctermfg=226 guibg=#5f5f00 guifg=#ffff00
  hi DiffDelete ctermbg=52 ctermfg=196 guibg=#5f0000 guifg=#ff0000
  hi DiffText ctermbg=58 ctermfg=226 guibg=#875f00 guifg=#ffff00
endif

" Recommended plugins for better Dark Tango experience:
" - PaperColor: colorscheme that works well with dark backgrounds
" - vim-gitgutter: for git indicators with dark theme suitable colors
" - vim-airline: status line with Tango-compatible themes
" Install with:
" mkdir -p ~/.vim/pack/plugins/start
" git clone https://github.com/NLKNguyen/papercolor-theme.git ~/.vim/pack/plugins/start/papercolor-theme
" git clone https://github.com/airblade/vim-gitgutter.git ~/.vim/pack/plugins/start/vim-gitgutter
" git clone https://github.com/vim-airline/vim-airline.git ~/.vim/pack/plugins/start/vim-airline

" Terminal-friendly mouse settings
" With mouse=, Vim's mouse handling is completely disabled
" allowing the terminal to handle all mouse interactions
" This lets you select and copy text using the terminal's selection mechanism

" Note: When mouse=, these settings below have no effect
" but are kept for reference/documentation