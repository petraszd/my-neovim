" Plugins
" -------

call plug#begin(stdpath('data') . '/plugged')

Plug 'git@github.com:junegunn/fzf.git'
Plug 'git@github.com:junegunn/fzf.vim.git'
Plug 'git@github.com:scrooloose/nerdtree.git'
Plug 'git@github.com:scrooloose/nerdcommenter.git'
Plug 'git@github.com:vim-scripts/Lucius.git'
Plug 'git@github.com:vim-airline/vim-airline.git'
Plug 'git@github.com:ziglang/zig.vim.git'
Plug 'git@github.com:mhinz/vim-grepper.git'
Plug 'git@github.com:prettier/vim-prettier.git'
Plug 'git@github.com:MaxMEllon/vim-jsx-pretty.git'
Plug 'git@github.com:Vimjas/vim-python-pep8-indent.git'
Plug 'git@github.com:habamax/vim-godot.git'
Plug 'git@github.com:EdenEast/nightfox.nvim.git'

Plug 'git@github.com:neovim/nvim-lspconfig'
Plug 'git@github.com:hrsh7th/cmp-nvim-lsp'
Plug 'git@github.com:hrsh7th/cmp-buffer'
Plug 'git@github.com:hrsh7th/cmp-path'
Plug 'git@github.com:hrsh7th/cmp-cmdline'
Plug 'git@github.com:hrsh7th/nvim-cmp'
Plug 'git@github.com:hrsh7th/cmp-vsnip'
Plug 'git@github.com:hrsh7th/vim-vsnip'
Plug 'git@github.com:rafamadriz/friendly-snippets.git'

call plug#end()


" Look
" ----

" set termguicolors
set textwidth=119
set number
set hlsearch
set t_Co=256
set termguicolors
lua << EOF
require('nightfox').setup({})
EOF
colorscheme nordfox


" Behaviour
" ---------

set exrc
set secure
set nohlsearch
set hlsearch

set clipboard+=unnamedplus
set completeopt=menuone,noselect
set shortmess+=c

" remapping
nmap <space>h <C-w>h
nmap <space>j <C-w>j
nmap <space>k <C-w>k
nmap <space>l <C-w>l
nmap <space>w <C-w>w
nmap <space>v <C-w>v
nmap <space>c <C-w>c
nmap <space>o <C-w>o

nmap <space>s :wa<CR>

nmap <space>e :Ex<CR>

inoremap kk <C-p>
inoremap jj <C-n>

" Removes trailing spaces
function! RemoveTrailingSpaces()
  let _s=@/
  let l = line(".")
  let c = col(".")
  %s/\s\+$//e
  let @/=_s
  call cursor(l, c)
endfunction
au BufWritePre * call RemoveTrailingSpaces()

" tabs
set tabstop=2 " tab size in spaces
set expandtab " expand tabs to spaces
set shiftwidth=2 " number of spaces used with (auto) indent,



" FileType
" --------

au FileType python,c,cpp,java,cg,gdscript setlocal shiftwidth=4 tabstop=4 et

" Make
autocmd FileType make setlocal noexpandtab
autocmd FileType make setlocal shiftwidth=8 shiftwidth=8 tabstop=8



" LSP
" ---

set completeopt=menu,menuone,noselect

lua <<EOF
require('my-lsp')
require('my-hover')
EOF

nmap <F1> :lua pz_hover()<CR>
nmap <F2> :lua vim.lsp.buf.rename()<CR>
nmap <F3> :lua vim.lsp.buf.definition()<CR>
nmap <F4> :lua vim.lsp.buf.format()<CR>


" Plugins Configs
" ---------------

" FZF
nmap <space>p :FZF<CR>

" FZF.vim
nmap <space>b :Buffers<CR>

" NERDCommenter
let g:mapleader = ','

" NERDTree
command Ex execute "e " . expand("%:p:h")
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1
let g:NERDTreeQuitOnOpen = 1

" grepper
let g:grepper = {}
let g:grepper.quickfix = 1
let g:grepper.tools = ['rg']
let g:grepper.highlight = 1

lua << EOF
require('grepper/f5')
EOF
