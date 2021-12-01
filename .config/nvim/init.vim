call plug#begin('~/AppData/Local/nvim/plugged')


"Python code completion" 
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins'}
Plug 'zchee/deoplete-jedi'

" Plug 'dracula/vim'                    " Dracula Theme
Plug 'ryanoasis/vim-devicons'           " Icons for files
Plug 'preservim/nerdtree'               " Directory tree
Plug 'mhinz/vim-startify'               " Vim Startup window
Plug 'morhetz/gruvbox'                  " Gruvbox theme
Plug 'vim-airline/vim-airline'          " Status bar and it's themes
Plug 'vim-airline/vim-airline-themes'   " Themes for status bar
Plug 'kyazdani42/nvim-web-devicons'     " Icons for Tabs
Plug 'romgrk/barbar.nvim'               " Tabs themselves
Plug 'jiangmiao/auto-pairs'             " Auto Bracketing
Plug 'nvim-lua/plenary.nvim'            " GitSigns 
Plug 'lewis6991/gitsigns.nvim'          " GitSigns
Plug 'liuchengxu/vista.vim'             " View and search LSP symbols
Plug 'scrooloose/syntastic'             " Syntax checking for anything 
Plug 'preservim/tagbar'                 " Displaying tags in file


" Rust related
Plug 'neovim/nvim-lspconfig'
Plug 'simrat39/rust-tools.nvim'

Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

" (Optional) Multi-entry selection UI.
Plug 'junegunn/fzf'

""" Optional dependencies
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-telescope/telescope.nvim'

""" Debugging (needs plenary from above as well)
Plug 'mfussenegger/nvim-dap'

call plug#end()


if (has("termguicolors"))
set termguicolors
endif
syntax enable
filetype plugin indent on
" open new split panes to right and below
set splitright
set splitbelow
"autocmd vimeter * ++nested colorscheme gruvbox
colorscheme gruvbox

set nocompatible            " disable compatibility to old-time vi
set showmatch               " show matching 
set ignorecase              " case insensitive 
set mouse=v                 " middle-click paste with 
set hlsearch                " highlight search 
set incsearch               " incremental search
set tabstop=4               " number of columns occupied by a tab 
set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
set expandtab               " converts tabs to white space
set shiftwidth=4            " width for autoindents
set autoindent              " indent a new line the same amount as the line just typed
set number                  " add line numbers
set wildmode=longest,list   " get bash-like tab completions
set cc=120                   " set an 80 column border for good coding style
filetype plugin indent on   "allow auto-indenting depending on file type
syntax on                   " syntax highlighting
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
filetype plugin on
set cursorline              " highlight current cursorline
set ttyfast                 " Speed up scrolling in Vim
set spell                   " enable spell check (may need to download language package)


" Copying and Pasting remapping "
" nmap <c-c> "+y
" vmap <c-c> "+y
" nmap <c-v> "+p
" inoremap <c-v> <c-r>+
" cnoremap <c-v> <c-r>+
" inoremap <c-r> <c-v>
map <silent> <S-Insert> "+p
imap <silent> <S-Insert> <Esc>"+pa

" NerdTree Mapping"
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

" Window Split Mapping "
nnoremap <C-j> <C-w><C-j>
nnoremap <C-k> <C-w><C-k>
nnoremap <C-l> <C-w><C-l>
nnoremap <C-h> <C-w><C-h>



" Move to previous/next
nnoremap <silent>    <A-,> :BufferPrevious<CR>
nnoremap <silent>    <A-.> :BufferNext<CR>
" Re-order to previous/next
nnoremap <silent>    <A-<> :BufferMovePrevious<CR>
nnoremap <silent>    <A->> :BufferMoveNext<CR>
" " Goto buffer in position...
nnoremap <silent>    <A-1> :BufferGoto 1<CR>
nnoremap <silent>    <A-2> :BufferGoto 2<CR>
nnoremap <silent>    <A-3> :BufferGoto 3<CR>
nnoremap <silent>    <A-4> :BufferGoto 4<CR>
nnoremap <silent>    <A-5> :BufferGoto 5<CR>
nnoremap <silent>    <A-6> :BufferGoto 6<CR>
nnoremap <silent>    <A-7> :BufferGoto 7<CR>
nnoremap <silent>    <A-8> :BufferGoto 8<CR>
nnoremap <silent>    <A-9> :BufferLast<CR>
" " Pin/unpin buffer
nnoremap <silent>    <A-p> :BufferPin<CR>
" " Close buffer
nnoremap <silent>    <A-c> :BufferClose<CR>
" " Wipeout buffer
" "                          :BufferWipeout<CR>
" " Close commands
" "                          :BufferCloseAllButCurrent<CR>
" "                          :BufferCloseAllButPinned<CR>
" "                          :BufferCloseBuffersLeft<CR>
" "                          :BufferCloseBuffersRight<CR>
" " Magic buffer-picking mode
 nnoremap <silent> <C-s>    :BufferPick<CR>
" " Sort automatically by...
 nnoremap <silent> <Space>bb :BufferOrderByBufferNumber<CR>
 nnoremap <silent> <Space>bd :BufferOrderByDirectory<CR>
 nnoremap <silent> <Space>bl :BufferOrderByLanguage<CR>
 nnoremap <silent> <Space>bw :BufferOrderByWindowNumber<CR>


let bufferline = get(g:, 'bufferline', {})
let bufferline.maximum_length = 40
let bufferline.maximum_padding = 5


"python3 host"
let g:python3_host_prog = expand('F:\Pythons\python3.8\python.exe')

let g:deoplete#enable_at_startup = 1


" Automatically start with file tree open"
autocmd VimEnter * NERDTree | wincmd p
set guifont=LiterationMono\ NF:h14



autocmd BufReadPost *.rs setlocal filetype=rust

" Required for operations modifying multiple buffers like rename.
set hidden

let g:LanguageClient_serverCommands = {
    \ 'rust': ['rustup', 'run', 'nightly', 'rls'],
    \ }

" Automatically start language servers.
let g:LanguageClient_autoStart = 1

" Maps K to hover, gd to goto definition, F2 to rename
nnoremap <silent> K :call LanguageClient_textDocument_hover()
nnoremap <silent> gd :call LanguageClient_textDocument_definition()
nnoremap <silent> <F2> :call LanguageClient_textDocument_rename()


" Tag bar 
nmap <F8> :TagbarToggle<CR>
