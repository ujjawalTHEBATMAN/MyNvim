-- lua/core/autocmds.lua
-- Autocommands

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
autocmd('TextYankPost', {
  group = augroup('highlight-yank', { clear = true }),
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

-- Auto-save on focus lost
autocmd('FocusLost', {
  group = augroup('auto-save', { clear = true }),
  pattern = '*',
  callback = function()
    if vim.bo.modified and vim.bo.filetype ~= '' and vim.bo.buftype == '' then vim.cmd 'silent! write' end
  end,
})

-- Cleanup LSP & Java processes on exit
autocmd('VimLeavePre', {
  group = augroup('cleanup-lsp', { clear = true }),
  desc = 'Stop all LSP clients and kill orphaned Java processes',
  callback = function()
    for _, client in ipairs(vim.lsp.get_clients()) do
      pcall(function() client.stop(true) end)
    end
    vim.wait(100, function() return false end)
    local nvim_pid = vim.fn.getpid()
    vim.fn.system(string.format("pkill -P %d -f 'java.*jdtls' 2>/dev/null; pkill -P %d -f 'nvim-java' 2>/dev/null", nvim_pid, nvim_pid))
  end,
})

-- Setup Java modules after plugins load
vim.defer_fn(function()
  local ok_runner, java_runner = pcall(require, 'java-runner')
  if ok_runner then
    java_runner.setup({ output_dir = 'out', terminal = { direction = 'horizontal', size = 15, close_on_exit = false } })
  end
  local ok_runtime, java_runtime = pcall(require, 'java-runtime')
  if ok_runtime then java_runtime.setup_keymaps() end
end, 2000)
