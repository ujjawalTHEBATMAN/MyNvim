-- lua/plugins/coding.lua
-- Coding enhancement plugins

return {
  -- Surround
  { 'kylechui/nvim-surround', version = '*', event = 'VeryLazy', config = function() require('nvim-surround').setup() end },

  -- Comment
  { 'numToStr/Comment.nvim', event = { 'BufReadPost', 'BufNewFile' }, opts = { toggler = { line = 'gcc', block = 'gbc' }, opleader = { line = 'gc', block = 'gb' }, extra = { above = 'gcO', below = 'gco', eol = 'gcA' } } },

  -- Autopairs
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      require('nvim-autopairs').setup({ check_ts = true, ts_config = { lua = { 'string', 'source' }, java = false }, disable_filetype = { 'TelescopePrompt', 'spectre_panel' }, enable_check_bracket_line = true, fast_wrap = { map = '<M-e>', chars = { '{', '[', '(', '"', "'" } } })
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      require('cmp').event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = '' } }))
    end,
  },

  -- Indent Blankline
  { 'lukas-reineke/indent-blankline.nvim', main = 'ibl', event = { 'BufReadPost', 'BufNewFile' }, opts = { indent = { char = '│', tab_char = '│' }, scope = { enabled = true, show_start = true, show_end = true }, exclude = { filetypes = { 'help', 'alpha', 'dashboard', 'Trouble', 'lazy', 'mason' } } } },

  -- Mini.indentscope
  {
    'echasnovski/mini.indentscope',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('mini.indentscope').setup({ symbol = '│', options = { try_as_border = true }, draw = { delay = 200, animation = require('mini.indentscope').gen_animation.none(), priority = 2 } })
      vim.api.nvim_create_autocmd('FileType', { pattern = { 'help', 'alpha', 'dashboard', 'neo-tree', 'Trouble', 'trouble', 'lazy', 'mason', 'notify', 'toggleterm', 'NvimTree' }, callback = function() vim.b.miniindentscope_disable = true end })
    end,
  },

  -- Illuminate (Highlight word under cursor)
  {
    'RRethy/vim-illuminate',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('illuminate').configure({ providers = { 'lsp', 'treesitter', 'regex' }, delay = 200, filetypes_denylist = { 'dirbuf', 'dirvish', 'fugitive', 'alpha', 'NvimTree', 'lazy', 'Trouble', 'dashboard', 'TelescopePrompt' }, under_cursor = true, min_count_to_highlight = 2 })
      vim.keymap.set('n', ']r', function() require('illuminate').next_reference({ wrap = true }) end, { desc = 'Next Reference' })
      vim.keymap.set('n', '[r', function() require('illuminate').next_reference({ reverse = true, wrap = true }) end, { desc = 'Prev Reference' })
    end,
  },

  -- Yanky (Yank history)
  {
    'gbprod/yanky.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    event = 'VeryLazy',
    config = function()
      require('yanky').setup({ highlight = { on_put = true, on_yank = true, timer = 200 }, picker = { telescope = { use_default_mappings = true } }, system_clipboard = { sync_with_ring = false } })
      require('telescope').load_extension('yank_history')
      vim.keymap.set({ 'n', 'x' }, 'y', '<Plug>(YankyYank)')
      vim.keymap.set({ 'n', 'x' }, 'p', '<Plug>(YankyPutAfter)')
      vim.keymap.set({ 'n', 'x' }, 'P', '<Plug>(YankyPutBefore)')
      vim.keymap.set('n', '<leader>yp', '<Plug>(YankyPreviousEntry)')
      vim.keymap.set('n', '<leader>yn', '<Plug>(YankyNextEntry)')
      vim.keymap.set('n', '<leader>sy', '<cmd>Telescope yank_history<cr>', { desc = 'Yank History' })
    end,
  },

  -- Conform (Formatting)
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    dependencies = { 'mason.nvim' },
    config = function()
      require('conform').setup({
        formatters_by_ft = { java = { 'google-java-format' }, lua = { 'stylua' }, python = { 'black' }, javascript = { 'prettier' }, typescript = { 'prettier' }, json = { 'prettier' }, yaml = { 'prettier' }, markdown = { 'prettier' } },
        format_on_save = function(bufnr) if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end; return { timeout_ms = 2000, lsp_fallback = true } end,
        formatters = { ['google-java-format'] = { command = vim.fn.stdpath('data') .. '/mason/bin/google-java-format', args = { '--aosp', '-' } } },
      })
      vim.keymap.set('n', '<leader>f', function() require('conform').format({ async = true }) end, { desc = 'Format' })
      vim.keymap.set('n', '<leader>tf', function() vim.b.disable_autoformat = not (vim.b.disable_autoformat or false); print('Autoformat: ' .. tostring(not vim.b.disable_autoformat)) end, { desc = 'Toggle Autoformat' })
    end,
  },

  -- Lint
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      local lint = require('lint')
      lint.linters_by_ft = { java = { 'checkstyle' }, lua = { 'luacheck' }, python = { 'flake8', 'pylint' }, javascript = { 'eslint' }, typescript = { 'eslint' }, json = { 'jsonlint' }, yaml = { 'yamllint' }, markdown = { 'markdownlint' }, bash = { 'shellcheck' }, sh = { 'shellcheck' } }
      vim.api.nvim_create_autocmd({ 'BufWritePost' }, { callback = function() require('lint').try_lint() end })
      vim.keymap.set('n', '<leader>l', function() lint.try_lint() end, { desc = 'Trigger Linting' })
    end,
  },

  -- Todo Comments
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('todo-comments').setup()
      vim.keymap.set('n', ']t', function() require('todo-comments').jump_next() end, { desc = 'Next Todo' })
      vim.keymap.set('n', '[t', function() require('todo-comments').jump_prev() end, { desc = 'Prev Todo' })
      vim.keymap.set('n', '<leader>st', '<cmd>TodoTelescope<cr>', { desc = 'Search Todos' })
    end,
  },

  -- Spectre (Search & Replace)
  {
    'nvim-pack/nvim-spectre',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>sr', function() require('spectre').toggle() end, desc = 'Spectre (Replace)' },
      { '<leader>sw', function() require('spectre').open_visual({ select_word = true }) end, desc = 'Spectre (Word)' },
      { '<leader>sf', function() require('spectre').open_file_search({ select_word = true }) end, desc = 'Spectre (File)' },
    },
  },

  -- Mini.ai (Text objects)
  {
    'echasnovski/mini.ai',
    event = 'VeryLazy',
    config = function()
      local ai = require('mini.ai')
      ai.setup({
        n_lines = 500,
        custom_textobjects = {
          g = function() return { from = { line = 1, col = 1 }, to = { line = vim.fn.line('$'), col = math.max(vim.fn.getline('$'):len(), 1) } } end,
          o = ai.gen_spec.treesitter({ a = { '@block.outer', '@conditional.outer', '@loop.outer' }, i = { '@block.inner', '@conditional.inner', '@loop.inner' } }, {}),
          f = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }, {}),
          c = ai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }, {}),
        },
      })
    end,
  },

  -- Refactoring
  {
    'ThePrimeagen/refactoring.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
    keys = {
      { '<leader>re', ':Refactor extract ', mode = 'x', desc = 'Extract Function' },
      { '<leader>rf', ':Refactor extract_to_file ', mode = 'x', desc = 'Extract to File' },
      { '<leader>rv', ':Refactor extract_var ', mode = 'x', desc = 'Extract Variable' },
      { '<leader>ri', ':Refactor inline_var', mode = { 'n', 'x' }, desc = 'Inline Variable' },
      { '<leader>rb', ':Refactor extract_block', mode = 'n', desc = 'Extract Block' },
    },
    config = function() require('refactoring').setup({}) end,
  },

  -- Undotree
  { 'mbbill/undotree', cmd = 'UndotreeToggle', keys = { { '<leader>u', vim.cmd.UndotreeToggle, desc = 'Undo Tree' } } },
}
