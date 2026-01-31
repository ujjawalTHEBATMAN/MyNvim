-- lua/core/keymaps.lua
-- Global Keymaps (non-plugin specific)

local map = vim.keymap.set

-- Clear search
map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear Search' })

-- NOTE: Window navigation (Alt+h/j/k/l) handled by smart-splits.nvim in plugins/editor.lua

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

-- Diagnostics
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Prev Diagnostic' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Next Diagnostic' })
map('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Line Diagnostics' })
map('n', '<leader>cl', vim.diagnostic.setloclist, { desc = 'Diagnostics to Loclist' })

-- Java Runner (set early so F5 works immediately)
local function smart_java_run()
  local ok, java_runner = pcall(require, 'java-runner')
  if ok then java_runner.run() else vim.notify('☕ Java runner loading...', vim.log.levels.WARN) end
end
map('n', '<F5>', smart_java_run, { noremap = true, silent = true, nowait = true, desc = '☕ Run Java' })
map('n', '<leader>rr', smart_java_run, { noremap = true, silent = true, nowait = true, desc = '☕ Run Java' })
