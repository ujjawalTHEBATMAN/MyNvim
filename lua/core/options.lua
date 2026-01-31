-- lua/core/options.lua
-- Core Neovim Options

local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.termguicolors = true
opt.signcolumn = 'yes'
opt.colorcolumn = '120'
opt.laststatus = 3
opt.showmode = false
opt.title = true
opt.titlestring = '%t - NVIM'

-- Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true
opt.breakindent = true

-- Search
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Behavior
opt.mouse = 'a'
opt.clipboard = 'unnamedplus'
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.updatetime = 250
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.linebreak = true

-- Performance (OPTIMIZED for high WPM)
opt.hidden = true
opt.lazyredraw = false  -- Keep false for noice.nvim compatibility
opt.synmaxcol = 240     -- Limit syntax highlighting for long lines
opt.ttyfast = true      -- Faster terminal connection
opt.regexpengine = 1    -- Use old regex engine (faster for some patterns)
opt.maxmempattern = 1000 -- Reduce memory for pattern matching

-- Additional Performance
vim.g.matchparen_timeout = 20      -- Faster matchparen
vim.g.matchparen_insert_timeout = 20
vim.g.loaded_python3_provider = 0  -- Disable unused providers
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

-- Diagnostics
vim.diagnostic.config {
  virtual_text = {
    prefix = '●',
    spacing = 4,
    source = 'if_many',
    format = function(d) return string.sub(d.message, 1, 60) .. (string.len(d.message) > 60 and '…' or '') end,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { focusable = true, style = 'minimal', border = 'rounded', source = 'always', header = '', prefix = '' },
}

-- Diagnostic signs
local signs = { Error = '', Warn = '', Hint = '󰌵', Info = '' }
for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
