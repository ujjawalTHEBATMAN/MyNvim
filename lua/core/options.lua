-- lua/core/options.lua
-- PERFORMANCE OPTIMIZED Core Neovim Options

local opt = vim.opt

-- ═══════════════════════════════════════════════════════════════════════
-- UI Settings
-- ═══════════════════════════════════════════════════════════════════════
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
opt.pumheight = 10        -- Limit completion menu height
opt.cmdheight = 1         -- Command line height
opt.showcmd = false       -- Don't show partial commands

-- ═══════════════════════════════════════════════════════════════════════
-- Indentation
-- ═══════════════════════════════════════════════════════════════════════
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true
opt.breakindent = true

-- ═══════════════════════════════════════════════════════════════════════
-- Search
-- ═══════════════════════════════════════════════════════════════════════
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- ═══════════════════════════════════════════════════════════════════════
-- Behavior
-- ═══════════════════════════════════════════════════════════════════════
opt.mouse = 'a'
opt.clipboard = 'unnamedplus'
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.updatetime = 200      -- Faster CursorHold
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.linebreak = true

-- ═══════════════════════════════════════════════════════════════════════
-- PERFORMANCE CRITICAL - Maximum Smoothness
-- ═══════════════════════════════════════════════════════════════════════
opt.hidden = true
opt.lazyredraw = false    -- Keep false for noice.nvim compatibility
opt.synmaxcol = 200       -- Limit syntax highlighting for long lines (reduced from 240)
opt.ttyfast = true        -- Faster terminal connection
opt.regexpengine = 1      -- Use old regex engine (faster)
opt.maxmempattern = 1000  -- Reduce memory for pattern matching

-- Reduce redraw frequency
opt.redrawtime = 1000     -- Time in ms for redrawing display
opt.ttimeoutlen = 10      -- Faster key sequence completion

-- Folding performance
opt.foldmethod = 'manual' -- Manual folding is fastest
opt.foldexpr = ''         -- No fold expressions
opt.foldlevel = 99
opt.foldlevelstart = 99

-- ═══════════════════════════════════════════════════════════════════════
-- Disable Providers (faster startup)
-- ═══════════════════════════════════════════════════════════════════════
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

-- Faster matchparen
vim.g.matchparen_timeout = 10
vim.g.matchparen_insert_timeout = 10

-- ═══════════════════════════════════════════════════════════════════════
-- Optimized Diagnostics
-- ═══════════════════════════════════════════════════════════════════════
vim.diagnostic.config({
  virtual_text = {
    prefix = '●',
    spacing = 4,
    source = false,  -- Don't show source for speed
    format = function(d)
      return string.sub(d.message, 1, 50) .. (string.len(d.message) > 50 and '…' or '')
    end,
  },
  signs = true,
  underline = false,        -- Disable underline for performance
  update_in_insert = false,
  severity_sort = true,
  float = {
    focusable = true,
    style = 'minimal',
    border = 'single',
    source = 'always',
  },
})

-- Diagnostic signs (Dracula colors)
local signs = { Error = '', Warn = '', Hint = '󰌵', Info = '' }
for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })  -- numhl = '' for speed
end

-- ═══════════════════════════════════════════════════════════════════════
-- Cursor Optimization (reduces cursor lag)
-- ═══════════════════════════════════════════════════════════════════════
opt.guicursor = 'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50'
opt.cursorlineopt = 'number'  -- Only highlight line number, not entire line

-- ═══════════════════════════════════════════════════════════════════════
-- Completion Performance
-- ═══════════════════════════════════════════════════════════════════════
opt.complete = ''           -- Disable complete scanning
opt.completeopt = 'menu,menuone,noselect'
