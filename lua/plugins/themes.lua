-- lua/plugins/themes.lua
-- OPTIMIZED: Only Dracula theme for maximum performance

return {
  -- ═══════════════════════════════════════════════════════════════════════
  -- DRACULA ONLY - Fast, clean, zero bloat
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'Mofiqul/dracula.nvim',
    name = 'dracula',
    priority = 1000,
    lazy = false,
    config = function()
      require('dracula').setup({
        -- Core settings
        transparent_bg = true,
        italic_comment = true,
        
        -- Colors (Dracula palette)
        colors = {
          bg = '#282A36',
          fg = '#F8F8F2',
          selection = '#44475A',
          comment = '#6272A4',
          red = '#FF5555',
          orange = '#FFB86C',
          yellow = '#F1FA8C',
          green = '#50FA7B',
          purple = '#BD93F9',
          cyan = '#8BE9FD',
          pink = '#FF79C6',
          bright_red = '#FF6E6E',
          bright_green = '#69FF94',
          bright_yellow = '#FFFFA5',
          bright_blue = '#D6ACFF',
          bright_magenta = '#FF92DF',
          bright_cyan = '#A4FFFF',
          bright_white = '#FFFFFF',
          menu = '#21222C',
          visual = '#3E4452',
          gutter_fg = '#4B5263',
          nontext = '#3B4048',
        },
        
        -- Overrides for better visibility
        overrides = function(colors)
          return {
            -- Better line number visibility
            LineNr = { fg = colors.comment },
            CursorLineNr = { fg = colors.cyan, bold = true },
            
            -- Smoother scrollbar integration
            ScrollbarHandle = { bg = colors.selection },
            
            -- Better completion menu
            Pmenu = { bg = colors.menu },
            PmenuSel = { bg = colors.selection, fg = colors.cyan },
            
            -- Better diagnostics
            DiagnosticVirtualTextError = { fg = colors.red, italic = true },
            DiagnosticVirtualTextWarn = { fg = colors.orange, italic = true },
            DiagnosticVirtualTextInfo = { fg = colors.cyan, italic = true },
            DiagnosticVirtualTextHint = { fg = colors.green, italic = true },
            
            -- Better git signs
            GitSignsAdd = { fg = colors.green },
            GitSignsChange = { fg = colors.yellow },
            GitSignsDelete = { fg = colors.red },
            
            -- Treesitter context
            TreesitterContext = { bg = colors.menu },
            TreesitterContextLineNumber = { fg = colors.cyan },
          }
        end,
      })
      
      -- Apply colorscheme
      vim.cmd.colorscheme('dracula')
      
      -- Save as last theme
      local cache_dir = vim.fn.stdpath('cache')
      vim.fn.mkdir(cache_dir, 'p')
      local file = io.open(cache_dir .. '/last_theme.txt', 'w')
      if file then
        file:write('dracula')
        file:close()
      end
    end,
  },
}
