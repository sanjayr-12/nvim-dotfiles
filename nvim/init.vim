call plug#begin('~/.vim/plugged')

" Essential plugins
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} " Syntax highlighting
Plug 'vim-airline/vim-airline'                             " Status bar
Plug 'tpope/vim-commentary'                                " Easy commenting
Plug 'junegunn/fzf', { 'do': './install --all' }           " Fuzzy finder
Plug 'junegunn/fzf.vim'                                    " Fzf integration with Vim

" Git highlighting
Plug 'lewis6991/gitsigns.nvim'     " Git signs for line changes
Plug 'tpope/vim-fugitive'         " Git commands integration

" Theme
Plug 'morhetz/gruvbox'

" Prettier
Plug 'jose-elias-alvarez/null-ls.nvim'   " Null-ls for formatting and linting
Plug 'nvim-lua/plenary.nvim'            " Required dependency for null-ls

" File Tree
Plug 'nvim-tree/nvim-tree.lua'

" Icons for File Tree and Bufferline
Plug 'nvim-tree/nvim-web-devicons'

" Tabline Plugin for Buffers
Plug 'akinsho/bufferline.nvim'

" Icons
Plug 'ryanoasis/vim-devicons'

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

" Encoding
set encoding=UTF-8

" Map Ctrl+Z to undo
nnoremap <C-z> u
inoremap <C-z> <C-o>u
vnoremap <C-z> u

" Map Ctrl+Y to redo
nnoremap <C-y> <C-r>
inoremap <C-y> <C-o><C-r>
vnoremap <C-y> <C-r>

" Automatically insert closing brackets
inoremap ( ()<Esc>i
inoremap { {}<Esc>i
inoremap [ []<Esc>i
inoremap " ""<Esc>i
inoremap ' ''<Esc>i

" Prettier
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a

" Toggle File Tree
nnoremap <C-t> :NvimTreeToggle<CR>

" Navigate Between Buffers (Tabs)
nnoremap <Tab> :BufferLineCycleNext<CR>
nnoremap <S-Tab> :BufferLineCyclePrev<CR>

" Close the Current Buffer
nnoremap <C-w> :bd<CR>

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

" nvim-tree Setup
lua << EOF
local nvim_tree = require("nvim-tree")

local function my_on_attach(bufnr)
  local api = require("nvim-tree.api")

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- Default key mappings
  vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
  vim.keymap.set('n', 'c', api.fs.create, opts('Create'))
  vim.keymap.set('n', 'd', api.fs.remove, opts('Delete'))
  vim.keymap.set('n', '<C-t>', api.tree.toggle, opts('Toggle Tree'))
end

nvim_tree.setup({
  on_attach = my_on_attach,
  view = {
    width = 30,
    side = "left",
  },
  renderer = {
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
    },
  },
})
EOF

" Bufferline Setup
lua << EOF
require("bufferline").setup({
  options = {
    numbers = "ordinal",
    close_command = "bdelete! %d",
    separator_style = "slant",
    diagnostics = "nvim_lsp",
    offsets = {
      {
        filetype = "NvimTree",
        text = "File Explorer",
        highlight = "Directory",
        text_align = "center",
      },
    },
  },
})
EOF

" Git Signs Setup
lua << EOF
require('gitsigns').setup {
    signs = {
        add          = { text = '│' },
        change       = { text = '│' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
    },
    current_line_blame = true,
    watch_gitdir = { interval = 1000 },
    sign_priority = 6,
    update_debounce = 200,
}
EOF


" Toggle vertical split with Ctrl+\
function! ToggleVerticalSplit()
  " Check if there is only one window open
  if winnr('$') == 1
    " Open a vertical split
    vsplit
  else
    " Close the current split
    quit
  endif
endfunction

" Map Ctrl+\ to toggle the vertical split
nnoremap <C-\> :call ToggleVerticalSplit()<CR>



