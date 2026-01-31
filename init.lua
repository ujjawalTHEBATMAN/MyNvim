-- ~/.config/nvim/init.lua
-- Minimal bootstrap - actual config in lua/core/ and lua/plugins/

-- Leader keys (MUST be before any plugin loads)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Load core modules
require('core.options')
require('core.keymaps')
require('core.autocmds')

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins (lazy.nvim auto-imports from lua/plugins/)
require('lazy').setup({
  { import = 'plugins' },
}, {
  defaults = { lazy = false, version = false },
  install = { missing = true, colorscheme = { 'catppuccin', 'habamax' } },
  checker = { enabled = true, notify = false, frequency = 86400 },
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = { 'gzip', 'matchit', 'matchparen', 'netrwPlugin', 'tarPlugin', 'tohtml', 'tutor', 'zipPlugin' },
    },
  },
})
