-- lua/plugins/themes.lua
-- Theme plugins (curated selection for performance)

return {
  -- Main theme (loads first)
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    lazy = false,
    config = function()
      require('catppuccin').setup({
        flavour = 'mocha',
        transparent_background = true,
        term_colors = true,
        dim_inactive = { enabled = true, shade = 'dark', percentage = 0.15 },
        styles = { comments = { 'italic' }, conditionals = { 'italic' }, functions = { 'bold' }, types = { 'bold' }, keywords = { 'italic' } },
        integrations = {
          cmp = true, gitsigns = true, nvimtree = true, treesitter = true, bufferline = true, lualine = true,
          native_lsp = { enabled = true, virtual_text = { errors = { 'italic' }, hints = { 'italic' }, warnings = { 'italic' }, information = { 'italic' } }, underlines = { errors = { 'underline' }, hints = { 'underline' }, warnings = { 'underline' }, information = { 'underline' } } },
          mason = true, which_key = true, telescope = { enabled = true, style = 'nvchad' }, harpoon = true, dap = true, dap_ui = true, indent_blankline = true,
        },
      })
      vim.cmd.colorscheme('catppuccin')
      vim.defer_fn(function() local ok, themes = pcall(require, 'themes'); if ok then themes.setup() end end, 100)
    end,
  },

  -- ========================================
  -- TIER 1: Essential Dark Themes (Always Available)
  -- ========================================
  { 'rose-pine/neovim', name = 'rose-pine', lazy = true },
  { 'rebelot/kanagawa.nvim', lazy = true },
  { 'folke/tokyonight.nvim', lazy = true, priority = 1000 },
  { 'ellisonleao/gruvbox.nvim', lazy = true, priority = 1000 },

  -- ========================================
  -- TIER 2: Professional (Load on demand)
  -- ========================================
  { 'navarasu/onedark.nvim', lazy = true },
  { 'EdenEast/nightfox.nvim', lazy = true },
  { 'Mofiqul/dracula.nvim', lazy = true },

  -- ========================================
  -- TIER 3: Aesthetic Extras (Load on demand)
  -- ========================================
  { 'sainnhe/everforest', lazy = true },
  { 'sainnhe/sonokai', lazy = true },
  { 'nyoom-engineering/oxocarbon.nvim', lazy = true },
  { 'scottmckendry/cyberdream.nvim', lazy = true },
  { 'Mofiqul/vscode.nvim', lazy = true },

  -- NOTE: Reduced from 30+ themes to 12 essential ones for faster startup
  -- The themes/init.lua theme switcher will still work with these
}
