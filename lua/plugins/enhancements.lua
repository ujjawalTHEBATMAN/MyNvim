-- lua/plugins/enhancements.lua
-- PERFORMANCE OPTIMIZED enhancement plugins

return {
  -- ═══════════════════════════════════════════════════════════════════════
  -- UFO (Folding) - Optimized
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    event = 'BufReadPost',
    init = function()
      vim.o.foldcolumn = '1'
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
    opts = {
      provider_selector = function(bufnr, filetype)
        -- Use indent for large files (faster), treesitter otherwise
        local max_filesize = 100 * 1024  -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
        if ok and stats and stats.size > max_filesize then
          return { 'indent' }
        end
        return { 'treesitter', 'indent' }
      end,
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- HLSLENS (Enhanced search) - Simplified
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'kevinhwang91/nvim-hlslens',
    event = 'BufReadPost',
    config = function()
      require('hlslens').setup({
        calm_down = true,
        nearest_only = true,
        nearest_float_when = 'never',  -- Disable float for performance
      })
      
      local opts = { noremap = true, silent = true }
      vim.keymap.set('n', 'n', [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>zz]], opts)
      vim.keymap.set('n', 'N', [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>zz]], opts)
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- COLORIZER - Only for specific filetypes
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'NvChad/nvim-colorizer.lua',
    event = 'BufReadPost',
    opts = {
      filetypes = { 'css', 'scss', 'html', 'lua' },  -- Reduced filetypes
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        names = false,
        RRGGBBAA = false,
        rgb_fn = false,
        hsl_fn = false,
        css = false,
        tailwind = false,
        mode = 'background',
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- ZEN MODE
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'folke/zen-mode.nvim',
    cmd = 'ZenMode',
    keys = { { '<leader>zz', '<cmd>ZenMode<cr>', desc = 'Zen Mode' } },
    opts = {
      window = {
        backdrop = 0.95,
        width = 120,
        options = { number = true, relativenumber = true },
      },
      plugins = { twilight = { enabled = false } },  -- Disable twilight for speed
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- BQF (Better Quickfix)
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
    opts = {
      auto_enable = true,
      auto_resize_height = true,
      preview = { win_height = 10 },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- NEOTEST - On-demand only
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'rcasia/neotest-java',
    },
    keys = {
      { '<leader>tn', function() require('neotest').run.run() end, desc = 'Run Nearest Test' },
      { '<leader>tF', function() require('neotest').run.run(vim.fn.expand('%')) end, desc = 'Run File Tests' },
      { '<leader>tS', function() require('neotest').summary.toggle() end, desc = 'Toggle Test Summary' },
      { '<leader>to', function() require('neotest').output.open({ enter = true }) end, desc = 'Show Test Output' },
    },
    config = function()
      require('neotest').setup({
        adapters = {
          require('neotest-java')({ ignore_wrapper = false }),
        },
      })
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- KULALA (HTTP Client)
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'mistweaverco/kulala.nvim',
    keys = {
      { '<leader>Rr', function() require('kulala').run() end, desc = 'Send Request' },
      { '<leader>Rp', function() require('kulala').jump_prev() end, desc = 'Prev Request' },
      { '<leader>Rn', function() require('kulala').jump_next() end, desc = 'Next Request' },
    },
    opts = {},
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- VIM-DADBOD (Database)
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      { 'tpope/vim-dadbod', lazy = true },
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
    },
    cmd = { 'DBUI', 'DBUIToggle' },
    keys = { { '<leader>D', '<cmd>DBUIToggle<cr>', desc = 'Toggle DB UI' } },
    init = function() vim.g.db_ui_use_nerd_fonts = 1 end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- MARKDOWN PREVIEW
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview' },
    build = 'cd app && yarn install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_theme = 'dark'
    end,
    ft = { 'markdown' },
    keys = { { '<leader>mp', '<cmd>MarkdownPreviewToggle<cr>', desc = 'Markdown Preview' } },
  },

  -- NOTE: Removed Codeium (AI autocomplete) - use Gen.nvim instead
  -- NOTE: Removed Twilight - merged with zen-mode
  -- NOTE: Removed vim-visual-multi - rarely used, adds overhead
}
