-- lua/plugins/coding.lua
-- PERFORMANCE OPTIMIZED coding enhancement plugins

return {
  -- ═══════════════════════════════════════════════════════════════════════
  -- SURROUND
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'kylechui/nvim-surround',
    version = '*',
    event = 'VeryLazy',
    config = function() require('nvim-surround').setup() end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- COMMENT
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'numToStr/Comment.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      toggler = { line = 'gcc', block = 'gbc' },
      opleader = { line = 'gc', block = 'gb' },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- AUTOPAIRS
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
      require('nvim-autopairs').setup({
        check_ts = true,
        disable_filetype = { 'TelescopePrompt', 'spectre_panel' },
        fast_wrap = { map = '<M-e>' },
      })
      
      local cmp_ok, cmp = pcall(require, 'cmp')
      if cmp_ok then
        local cmp_autopairs_ok, cmp_autopairs = pcall(require, 'nvim-autopairs.completion.cmp')
        if cmp_autopairs_ok then
          cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
        end
      end
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- INDENT BLANKLINE (single indent plugin - removed mini.indentscope)
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      indent = { char = '│' },
      scope = { enabled = false },  -- Disable scope for performance
      exclude = {
        filetypes = { 'help', 'alpha', 'dashboard', 'Trouble', 'lazy', 'mason', 'NvimTree' },
      },
    },
  },

  -- NOTE: mini.indentscope REMOVED - caused scroll lag even with animations disabled

  -- ═══════════════════════════════════════════════════════════════════════
  -- ILLUMINATE (Highlight word under cursor) - Optimized
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'RRethy/vim-illuminate',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('illuminate').configure({
        providers = { 'lsp', 'treesitter' },  -- Removed regex provider
        delay = 300,  -- Increased delay for performance
        filetypes_denylist = { 'alpha', 'NvimTree', 'lazy', 'Trouble', 'TelescopePrompt' },
        under_cursor = true,
        min_count_to_highlight = 2,
        large_file_cutoff = 2000,  -- Disable for large files
      })
      
      vim.keymap.set('n', ']r', function() require('illuminate').next_reference({ wrap = true }) end, { desc = 'Next Reference' })
      vim.keymap.set('n', '[r', function() require('illuminate').next_reference({ reverse = true, wrap = true }) end, { desc = 'Prev Reference' })
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- YANKY (Yank history)
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'gbprod/yanky.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    event = 'VeryLazy',
    config = function()
      require('yanky').setup({
        highlight = { on_put = true, on_yank = true, timer = 150 },
        system_clipboard = { sync_with_ring = false },
      })
      
      pcall(function() require('telescope').load_extension('yank_history') end)
      
      vim.keymap.set({ 'n', 'x' }, 'y', '<Plug>(YankyYank)')
      vim.keymap.set({ 'n', 'x' }, 'p', '<Plug>(YankyPutAfter)')
      vim.keymap.set({ 'n', 'x' }, 'P', '<Plug>(YankyPutBefore)')
      vim.keymap.set('n', '<leader>sy', '<cmd>Telescope yank_history<cr>', { desc = 'Yank History' })
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- CONFORM (Formatting)
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    config = function()
      require('conform').setup({
        formatters_by_ft = {
          java = { 'google-java-format' },
          lua = { 'stylua' },
          python = { 'black' },
          javascript = { 'prettier' },
          typescript = { 'prettier' },
          json = { 'prettier' },
          yaml = { 'prettier' },
        },
        format_on_save = function(bufnr)
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
          return { timeout_ms = 2000, lsp_fallback = true }
        end,
      })
      
      vim.keymap.set('n', '<leader>f', function() require('conform').format({ async = true }) end, { desc = 'Format' })
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- LINT
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      local lint = require('lint')
      lint.linters_by_ft = {
        java = { 'checkstyle' },
        lua = { 'luacheck' },
        python = { 'flake8' },
        javascript = { 'eslint' },
        typescript = { 'eslint' },
      }
      
      vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
        callback = function() lint.try_lint() end,
      })
      
      vim.keymap.set('n', '<leader>l', function() lint.try_lint() end, { desc = 'Trigger Linting' })
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- TODO COMMENTS
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {},
    keys = {
      { ']t', function() require('todo-comments').jump_next() end, desc = 'Next Todo' },
      { '[t', function() require('todo-comments').jump_prev() end, desc = 'Prev Todo' },
      { '<leader>st', '<cmd>TodoTelescope<cr>', desc = 'Search Todos' },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- SPECTRE (Search & Replace)
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'nvim-pack/nvim-spectre',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>sr', function() require('spectre').toggle() end, desc = 'Spectre (Replace)' },
      { '<leader>sw', function() require('spectre').open_visual({ select_word = true }) end, desc = 'Spectre (Word)' },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- MINI.AI (Text objects)
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'echasnovski/mini.ai',
    event = 'VeryLazy',
    config = function()
      local ai = require('mini.ai')
      ai.setup({
        n_lines = 300,  -- Reduced for performance
        custom_textobjects = {
          f = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }, {}),
          c = ai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }, {}),
        },
      })
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- REFACTORING
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'ThePrimeagen/refactoring.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
    keys = {
      { '<leader>re', ':Refactor extract ', mode = 'x', desc = 'Extract Function' },
      { '<leader>rf', ':Refactor extract_to_file ', mode = 'x', desc = 'Extract to File' },
      { '<leader>rv', ':Refactor extract_var ', mode = 'x', desc = 'Extract Variable' },
      { '<leader>ri', ':Refactor inline_var', mode = { 'n', 'x' }, desc = 'Inline Variable' },
    },
    config = function() require('refactoring').setup({}) end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- UNDOTREE
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    keys = { { '<leader>u', vim.cmd.UndotreeToggle, desc = 'Undo Tree' } },
  },
}
