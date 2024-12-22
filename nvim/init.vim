call plug#begin('~/.vim/plugged')

" Essential plugins
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} " Syntax highlighting
Plug 'preservim/nerdtree'                                  " File explorer
Plug 'vim-airline/vim-airline'                             " Status bar
Plug 'tpope/vim-commentary'                                " Easy commenting
Plug 'junegunn/fzf', { 'do': './install --all' }           " Fuzzy finder
Plug 'junegunn/fzf.vim'                                    " Fzf integration with Vim

" Theme
Plug 'morhetz/gruvbox'

" nvim-cmp for auto-completion
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'L3MON4D3/LuaSnip'          " Snippet engine
Plug 'saadparwaiz1/cmp_luasnip'  " Snippet completion for cmp

" LSP and Mason plugins
Plug 'neovim/nvim-lspconfig'         " LSP Configurations
Plug 'williamboman/mason.nvim'       " Mason for managing LSPs
Plug 'williamboman/mason-lspconfig.nvim'

call plug#end()

" General Settings
set number          " Show line numbers
syntax on           " Enable syntax highlighting
set tabstop=4       " Set tab width to 4 spaces
set shiftwidth=4    " Indent by 4 spaces
set expandtab       " Use spaces instead of tabs
set background=dark " Use dark theme
colorscheme gruvbox " Set the theme
set showmatch       " Highlight matching brackets

" Keymap for NERDTree
nnoremap <C-f> :NERDTreeToggle<CR>

" Map Ctrl+Z to undo
nnoremap <C-z> u
inoremap <C-z> <C-o>u
vnoremap <C-z> u

" Map Ctrl+Y to redo
nnoremap <C-y> <C-r>
inoremap <C-y> <C-o><C-r>
vnoremap <C-y> <C-r>

" Auto-save when leaving Insert mode or after a delay
autocmd InsertLeave,TextChanged * silent! write


" Automatically insert closing brackets
inoremap ( ()<Esc>i
inoremap { {}<Esc>i
inoremap [ []<Esc>i
inoremap " ""<Esc>i
inoremap ' ''<Esc>i

" Enable nvim-cmp
lua << EOF
local cmp = require'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)  -- Snippet support
    end,
  },
  mapping = {
    ['<Down>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<Up>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Confirm selected suggestion
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),
})
EOF



" Mason and LSP Setup
lua << EOF
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "tsserver", "jdtls", "gopls", "clangd" },
})

local lspconfig = require("lspconfig")

-- Configure LSP servers
local servers = { "tsserver", "jdtls", "gopls", "clangd" }
for _, server in ipairs(servers) do
  lspconfig[server].setup({
    on_attach = function(client, bufnr)
      local bufopts = { noremap=true, silent=true, buffer=bufnr }
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
    end,
  })
end
EOF

