" Plugins
" -------

call plug#begin(stdpath('data') . '/plugged')

Plug 'git@github.com:junegunn/fzf.git'
Plug 'git@github.com:junegunn/fzf.vim.git'
Plug 'git@github.com:scrooloose/nerdtree.git'
Plug 'git@github.com:scrooloose/nerdcommenter.git'
Plug 'git@github.com:vim-scripts/Lucius.git'
Plug 'git@github.com:vim-airline/vim-airline.git'
Plug 'git@github.com:neovim/nvim-lspconfig'
Plug 'git@github.com:/sirver/ultisnips'
Plug 'git@github.com:/honza/vim-snippets'
Plug 'git@github.com:ziglang/zig.vim.git'
Plug 'git@github.com:hrsh7th/nvim-compe.git'
Plug 'git@github.com:mhinz/vim-grepper.git'
Plug 'git@github.com:prettier/vim-prettier.git'
Plug 'git@github.com:MaxMEllon/vim-jsx-pretty.git'
Plug 'git@github.com:Vimjas/vim-python-pep8-indent.git'
Plug 'git@github.com:habamax/vim-godot.git'

call plug#end()



" Look
" ----

" set termguicolors
set textwidth=119
set number
set hlsearch
set t_Co=256
colorscheme lucius



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

lua << EOF
require('my-lsp/clangd')
require('my-lsp/pylsp')
require('my-lsp/zig')
require('my-lsp/omnisharp')
require('my-lsp/eslint')
require('my-lsp/tsserver')
require('my-lsp/cssls')
require('my-lsp/godot')
EOF

nmap <F2> :lua vim.lsp.buf.rename()<CR>
nmap <F3> :lua vim.lsp.buf.definition()<CR>


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

" UltiSnips
" <tab> conflicts with completion
let g:UltiSnipsExpandTrigger = '\<C-j>'
let g:UltiSnipsListSnippets = '\<C-j>'
let g:UltiSnipsJumpForwardTrigger = '\<C-j>'
let g:UltiSnipsJumpBackwardTrigger = '\<C-k>'

" nvim-compe
let g:compe = {}
let g:compe.enabled = v:true
let g:compe.autocomplete = v:true
let g:compe.debug = v:false
let g:compe.min_length = 2
let g:compe.preselect = 'enable'
let g:compe.throttle_time = 80
let g:compe.source_timeout = 200
let g:compe.incomplete_delay = 400
let g:compe.max_abbr_width = 100
let g:compe.max_kind_width = 100
let g:compe.max_menu_width = 100
let g:compe.documentation = v:true

let g:compe.source = {}
let g:compe.source.path = v:true
let g:compe.source.buffer = v:true
let g:compe.source.calc = v:true
let g:compe.source.nvim_lsp = v:true
let g:compe.source.nvim_lua = v:true
let g:compe.source.ultisnips = v:true

inoremap <silent><expr> <C-Space> compe#complete()
inoremap <silent><expr> <CR>      compe#confirm('<CR>')
inoremap <silent><expr> <C-e>     compe#close('<C-e>')

lua << EOF
require('compe/tab')
EOF

" grepper
let g:grepper = {}
let g:grepper.quickfix = 1
let g:grepper.tools = ['rg']
let g:grepper.highlight = 1

lua << EOF
require('grepper/f5')
EOF
