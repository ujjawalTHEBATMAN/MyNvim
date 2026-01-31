-- ~/.config/nvim/init.lua
-- =============================================================================
-- COMPLETE NVIM INITIALIZATION - FIXED & ENHANCED
-- =============================================================================

-- LEADER KEYS FIRST (Must be before any plugin loads)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- =============================================================================
-- CORE OPTIONS
-- =============================================================================
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

-- Performance
opt.hidden = true
opt.lazyredraw = false
opt.synmaxcol = 240

-- =============================================================================
-- EMERGENCY JAVA RUNNER (Before plugins load)
-- =============================================================================
local function emergency_java_run()
  if vim.bo.filetype == 'java' then
    local ok, java_config = pcall(require, 'java-config')
    if ok and java_config.run_main_floating then
      java_config.run_main_floating()
    else
      vim.defer_fn(function()
        local ok2, jc = pcall(require, 'java-config')
        if ok2 and jc.run_main_floating then
          jc.run_main_floating()
        else
          vim.notify('Java config not loaded yet, try again in a moment', vim.log.levels.WARN)
        end
      end, 500)
    end
  else
    -- Try to run make or just save
    if vim.fn.filereadable 'Makefile' == 1 then
      vim.cmd 'make'
    else
      vim.cmd 'write'
      vim.notify('File saved (no Makefile found)', vim.log.levels.INFO)
    end
  end
end

-- Set emergency keymaps immediately
vim.keymap.set('n', '<F5>', emergency_java_run, { noremap = true, silent = true, nowait = true, desc = 'RUN JAVA' })
vim.keymap.set('n', '<leader>rr', emergency_java_run, { noremap = true, silent = true, nowait = true, desc = 'RUN JAVA MAIN' })

-- =============================================================================
-- BOOTSTRAP LAZY.NVIM
-- =============================================================================
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- =============================================================================
-- LOAD PLUGINS
-- =============================================================================
require('lazy').setup({
  { import = 'plugins' },
}, {
  defaults = { lazy = false, version = false },
  install = { missing = true, colorscheme = { 'catppuccin', 'habamax' } },
  checker = { enabled = true, notify = false, frequency = 86400 },
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip',
        'matchit',
        'matchparen',
        'netrwPlugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
})

-- =============================================================================
-- GLOBAL KEYMAPS (Non-plugin specific)
-- =============================================================================
local map = vim.keymap.set

-- Clear search
map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear Search' })

-- Window navigation
map('n', '<C-h>', '<C-w>h', { desc = 'Go Left' })
map('n', '<C-j>', '<C-w>j', { desc = 'Go Down' })
map('n', '<C-k>', '<C-w>k', { desc = 'Go Up' })
map('n', '<C-l>', '<C-w>l', { desc = 'Go Right' })

-- Window management
map('n', '<leader>sv', '<C-w>v', { desc = 'Split Vertical' })
map('n', '<leader>sh', '<C-w>s', { desc = 'Split Horizontal' })
map('n', '<leader>se', '<C-w>=', { desc = 'Equal Splits' })
map('n', '<leader>sx', '<cmd>close<CR>', { desc = 'Close Split' })

-- Buffer management
map('n', '<leader>w', '<cmd>w<CR>', { desc = 'Save' })
map('n', '<leader>q', '<cmd>q<CR>', { desc = 'Quit' })
map('n', '<leader>Q', '<cmd>qa!<CR>', { desc = 'Force Quit All' })

-- Move lines in visual mode
map('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move Down', silent = true })
map('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move Up', silent = true })

-- Keep cursor centered
map('n', 'J', 'mzJ`z', { desc = 'Join Lines' })
map('n', '<C-d>', '<C-d>zz', { desc = 'Half Page Down' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Half Page Up' })
map('n', 'n', 'nzzzv', { desc = 'Next Search' })
map('n', 'N', 'Nzzzv', { desc = 'Prev Search' })

-- Paste without losing register
map('x', 'p', [["_dP]], { desc = 'Paste Without Yank' })

-- Yank to system clipboard
map({ 'n', 'v' }, '<leader>y', [["+y]], { desc = 'Yank to System' })
map('n', '<leader>Y', [["+Y]], { desc = 'Yank Line to System' })

-- Delete to void register
map({ 'n', 'v' }, '<leader>d', [["_d]], { desc = 'Delete to Void' })

-- Formatting
map('n', '<leader>lf', function() vim.lsp.buf.format() end, { desc = 'LSP Format' })

-- =============================================================================
-- RE-ASSERT JAVA KEYMAPS AFTER PLUGINS LOAD
-- =============================================================================
vim.defer_fn(function()
  -- Remove any conflicting mappings
  pcall(vim.keymap.del, 'n', '<F5>')
  pcall(vim.keymap.del, 'n', '<leader>rr')

  -- Re-set with highest priority
  vim.keymap.set('n', '<F5>', emergency_java_run, {
    noremap = true,
    silent = true,
    nowait = true,
    desc = '🔥 RUN JAVA (F5)',
  })

  vim.keymap.set('n', '<leader>rr', emergency_java_run, {
    noremap = true,
    silent = true,
    nowait = true,
    desc = '🔥 RUN JAVA MAIN',
  })

  -- Load Java runtime switcher keymaps
  local ok, java_runtime = pcall(require, 'java-runtime')
  if ok then java_runtime.setup_keymaps() end

  vim.notify('✅ Java keymaps active | F5 or <leader>rr to run', vim.log.levels.INFO)
end, 2000)

-- =============================================================================
-- AUTO COMMANDS
-- =============================================================================
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
autocmd('TextYankPost', {
  group = augroup('highlight-yank', { clear = true }),
  desc = 'Highlight on yank',
  callback = function() vim.highlight.on_yank { higroup = 'IncSearch', timeout = 200 } end,
})

-- Return to last position when opening files
autocmd('BufReadPost', {
  group = augroup('last-position', { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
  end,
})

-- Auto-save on focus lost (optional - remove if undesired)
autocmd('FocusLost', {
  group = augroup('auto-save', { clear = true }),
  pattern = '*',
  callback = function()
    if vim.bo.modified and vim.bo.filetype ~= '' and vim.bo.buftype == '' then vim.cmd 'silent! write' end
  end,
})

-- =============================================================================
-- DIAGNOSTICS CONFIGURATION
-- =============================================================================
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
  float = {
    focusable = true,
    style = 'minimal',
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
  },
}

-- Diagnostic signs
local signs = { Error = '', Warn = '', Hint = '󰌵', Info = '' }
for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Diagnostic keymaps
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Prev Diagnostic' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Next Diagnostic' })
map('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Line Diagnostics' })
map('n', '<leader>cl', vim.diagnostic.setloclist, { desc = 'Diagnostics to Loclist' })
