call plug#begin('~/.vim/plugged')

" Essential plugins
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} " Syntax highlighting
Plug 'preservim/nerdtree'                                  " File explorer
Plug 'vim-airline/vim-airline'                             " Status bar
Plug 'tpope/vim-commentary'                                " Easy commenting
Plug 'junegunn/fzf', { 'do': './install --all' }           " Fuzzy finder
Plug 'junegunn/fzf.vim'                                    " Fzf integration with Vim


"Git highlighting
Plug 'lewis6991/gitsigns.nvim'     " Git signs for line changes
Plug 'tpope/vim-fugitive'         " Git commands integration


" Theme
Plug 'morhetz/gruvbox'

"prettier
Plug 'jose-elias-alvarez/null-ls.nvim'   " Null-ls for formatting and linting
Plug 'nvim-lua/plenary.nvim'            " Required dependency for null-ls


"file tree, that top tabs
" File Tree Plugin
Plug 'nvim-tree/nvim-tree.lua'

" Icons for File Tree and Bufferline
Plug 'nvim-tree/nvim-web-devicons'

" Tabline Plugin for Buffers
Plug 'akinsho/bufferline.nvim'



" icons
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

"encoding
set encoding=UTF-8

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

" Custom function to create a new file in NERDTree
function! NERDTreeCreateFile()
  let l:node = g:NERDTreeFileNode.GetSelected()
  if !empty(l:node)
    let l:dir = l:node.path.str()
  else
    let l:dir = getcwd()
  endif
  let l:file = input("Create file: ", l:dir . "/", "file")
  if !empty(l:file)
    call system("touch " . shellescape(l:file))
    echo "Created file: " . l:file
    NERDTreeRefreshRoot
  endif
endfunction

" Custom function to create a new directory in NERDTree
function! NERDTreeCreateDir()
  let l:node = g:NERDTreeFileNode.GetSelected()
  if !empty(l:node)
    let l:dir = l:node.path.str()
  else
    let l:dir = getcwd()
  endif
  let l:dir_name = input("Create directory: ", l:dir . "/", "file")
  if !empty(l:dir_name)
    call system("mkdir -p " . shellescape(l:dir_name))
    echo "Created directory: " . l:dir_name
    NERDTreeRefreshRoot
  endif
endfunction

" Keybindings for file and folder creation in NERDTree
autocmd FileType nerdtree nmap <buffer> c :call NERDTreeCreateFile()<CR>
autocmd FileType nerdtree nmap <buffer> C :call NERDTreeCreateDir()<CR>


" Custom function to delete a file or directory in NERDTree
function! NERDTreeDeleteNode()
  let l:node = g:NERDTreeFileNode.GetSelected()
  if empty(l:node)
    echo "No file or directory selected!"
    return
  endif

  let l:path = l:node.path.str()
  let l:is_directory = l:node.isDirectory
  let l:message = "Are you sure you want to delete '" . l:path . "'? (y/n): "
  
  " Prompt the user for confirmation
  let l:confirm = input(l:message)
  if l:confirm ==# 'y'
    if l:is_directory
      call system("rm -rf " . shellescape(l:path))
    else
      call system("rm " . shellescape(l:path))
    endif
    echo "Deleted: " . l:path
    NERDTreeRefreshRoot
  else
    echo "Deletion cancelled."
  endif
endfunction

" Keybinding for deleting files or folders in NERDTree
autocmd FileType nerdtree nmap <buffer> d :call NERDTreeDeleteNode()<CR>



" Automatically insert closing brackets
inoremap ( ()<Esc>i
inoremap { {}<Esc>i
inoremap [ []<Esc>i
inoremap " ""<Esc>i
inoremap ' ''<Esc>i

"prettier
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a


"top tree
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


lua << EOF
local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier.with({
      filetypes = { "javascript", "typescript", "css", "html", "json", "markdown" },
    }),
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      -- Format on save
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })
    end
  end,
})
EOF




lua << EOF
-- Import the `nvim-tree` module
local nvim_tree = require("nvim-tree")

-- Define custom key mappings
local function my_on_attach(bufnr)
  local api = require("nvim-tree.api")

  -- Helper function to set key mappings
  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- Default key mappings
  vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
  vim.keymap.set('n', 'o', api.node.open.edit, opts('Open'))
  vim.keymap.set('n', 'v', api.node.open.vertical, opts('Open: Vertical Split'))
  vim.keymap.set('n', 's', api.node.open.horizontal, opts('Open: Horizontal Split'))
  vim.keymap.set('n', '<C-t>', api.tree.toggle, opts('Toggle Tree'))
  vim.keymap.set('n', 'd', api.fs.remove, opts('Delete'))
end

-- Configure nvim-tree
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

lua << EOF
require("bufferline").setup({
  options = {
    numbers = "ordinal", -- Show buffer numbers
    close_command = "bdelete! %d", -- Command to close a buffer
    right_mouse_command = "bdelete! %d", -- Right-click to close
    left_trunc_marker = "<", -- Truncation symbol for left
    right_trunc_marker = ">", -- Truncation symbol for right
    show_close_icon = true, -- Show close icon
    separator_style = "slant", -- Style of separator between tabs
    diagnostics = "nvim_lsp", -- Show LSP diagnostics on tabs
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

-- Keybindings for navigating tabs
vim.api.nvim_set_keymap("n", "<Tab>", ":BufferLineCycleNext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { noremap = true, silent = true })
EOF




lua << EOF
require('gitsigns').setup {
    signs = {
        add          = { text = '│' },
        change       = { text = '│' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
    },
    current_line_blame = true, -- Show inline blame annotations
    watch_gitdir = { interval = 1000 },
    sign_priority = 6,
    update_debounce = 200,
    max_file_length = 40000, -- Disable for very large files
}

-- Keymaps for GitSigns
local gs = require('gitsigns')

vim.keymap.set('n', ']c', function()
    if vim.wo.diff then return ']c' end
    vim.schedule(function() gs.next_hunk() end)
    return '<Ignore>'
end, { expr = true, desc = "Next Git hunk" })

vim.keymap.set('n', '[c', function()
    if vim.wo.diff then return '[c' end
    vim.schedule(function() gs.prev_hunk() end)
    return '<Ignore>'
end, { expr = true, desc = "Previous Git hunk" })

vim.keymap.set('n', '<leader>hs', gs.stage_hunk, { desc = "Stage Git hunk" })
vim.keymap.set('n', '<leader>hr', gs.reset_hunk, { desc = "Reset Git hunk" })
vim.keymap.set('n', '<leader>hR', gs.reset_buffer, { desc = "Reset Git buffer" })
vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { desc = "Preview Git hunk" })
vim.keymap.set('n', '<leader>hb', function() gs.blame_line { full = true } end, { desc = "Blame line" })
EOF

