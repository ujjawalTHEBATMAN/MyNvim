-- lua/plugins/enhancements.lua
-- Additional enhancement plugins

return {
  -- UFO (Folding)
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
    opts = { provider_selector = function() return { 'treesitter', 'indent' } end },
  },

  -- HLSlens (Enhanced search)
  {
    'kevinhwang91/nvim-hlslens',
    event = 'BufReadPost',
    config = function()
      require('hlslens').setup({ calm_down = true, nearest_only = true, nearest_float_when = 'always' })
      local opts = { noremap = true, silent = true }
      vim.keymap.set('n', 'n', [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>zz]], opts)
      vim.keymap.set('n', 'N', [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>zz]], opts)
      vim.keymap.set('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], opts)
      vim.keymap.set('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], opts)
    end,
  },

  -- Colorizer
  {
    'NvChad/nvim-colorizer.lua',
    event = 'BufReadPost',
    opts = { filetypes = { 'css', 'scss', 'html', 'javascript', 'typescript', 'lua', 'vim', 'conf' }, user_default_options = { RGB = true, RRGGBB = true, names = false, RRGGBBAA = true, rgb_fn = true, hsl_fn = true, css = true, css_fn = true, tailwind = false, mode = 'background', virtualtext = '■' } },
  },

  -- Vim-Visual-Multi
  { 'mg979/vim-visual-multi', branch = 'master', init = function() vim.g.VM_theme = 'purplegray' end, event = 'BufReadPost' },

  -- Zen Mode
  {
    'folke/zen-mode.nvim',
    cmd = 'ZenMode',
    keys = { { '<leader>zz', '<cmd>ZenMode<cr>', desc = 'Zen Mode' } },
    opts = { window = { backdrop = 0.95, width = 120, options = { number = true, relativenumber = true, signcolumn = 'no', cursorline = true } }, plugins = { twilight = { enabled = true }, gitsigns = { enabled = true } } },
  },

  -- Twilight
  { 'folke/twilight.nvim', cmd = { 'Twilight', 'TwilightEnable', 'TwilightDisable' }, keys = { { '<leader>tw', '<cmd>Twilight<cr>', desc = 'Toggle Twilight' } }, opts = { dimming = { alpha = 0.25 }, context = 10, treesitter = true } },

  -- BQF (Better Quickfix)
  {
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
    dependencies = { { 'junegunn/fzf', build = function() vim.fn['fzf#install']() end } },
    opts = { auto_enable = true, auto_resize_height = true, preview = { win_height = 12, show_title = true } },
  },

  -- Neotest
  {
    'nvim-neotest/neotest',
    dependencies = { 'nvim-neotest/nvim-nio', 'nvim-lua/plenary.nvim', 'antoinemadec/FixCursorHold.nvim', 'nvim-treesitter/nvim-treesitter', 'rcasia/neotest-java' },
    keys = {
      { '<leader>tn', function() require('neotest').run.run() end, desc = 'Run Nearest Test' },
      { '<leader>tF', function() require('neotest').run.run(vim.fn.expand('%')) end, desc = 'Run File Tests' },
      { '<leader>tS', function() require('neotest').summary.toggle() end, desc = 'Toggle Test Summary' },
      { '<leader>to', function() require('neotest').output.open({ enter = true }) end, desc = 'Show Test Output' },
      { '<leader>td', function() require('neotest').run.run({ strategy = 'dap' }) end, desc = 'Debug Nearest Test' },
    },
    config = function() require('neotest').setup({ adapters = { require('neotest-java')({ ignore_wrapper = false }) } }) end,
  },

  -- Codeium (AI autocomplete - disabled by default)
  {
    'Exafunction/codeium.vim',
    event = 'BufEnter',
    config = function()
      vim.g.codeium_enabled = false
      vim.g.codeium_disable_bindings = 1
      vim.keymap.set('i', '<M-g>', function() return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
      vim.keymap.set('i', '<C-;>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true, silent = true })
      vim.keymap.set('n', '<leader>ai', function()
        vim.g.codeium_enabled = not vim.g.codeium_enabled
        vim.cmd(vim.g.codeium_enabled and 'CodeiumEnable' or 'CodeiumDisable')
        vim.notify('🤖 AI Autocomplete ' .. (vim.g.codeium_enabled and 'ON' or 'OFF'), vim.g.codeium_enabled and vim.log.levels.INFO or vim.log.levels.WARN)
      end, { desc = 'Toggle AI' })
    end,
  },

  -- Kulala (HTTP Client)
  {
    'mistweaverco/kulala.nvim',
    keys = {
      { '<leader>Rr', function() require('kulala').run() end, desc = 'Send Request' },
      { '<leader>Rp', function() require('kulala').jump_prev() end, desc = 'Prev Request' },
      { '<leader>Rn', function() require('kulala').jump_next() end, desc = 'Next Request' },
      { '<leader>Ri', function() require('kulala').inspect() end, desc = 'Inspect Request' },
    },
    opts = {},
  },

  -- Vim-Dadbod (Database)
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = { { 'tpope/vim-dadbod', lazy = true }, { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true } },
    cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
    init = function() vim.g.db_ui_use_nerd_fonts = 1 end,
    keys = { { '<leader>D', '<cmd>DBUIToggle<cr>', desc = 'Toggle DB UI' } },
  },

  -- Markdown Preview
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && yarn install',
    init = function() vim.g.mkdp_filetypes = { 'markdown' }; vim.g.mkdp_auto_start = 0; vim.g.mkdp_auto_close = 1; vim.g.mkdp_theme = 'dark' end,
    ft = { 'markdown' },
    keys = { { '<leader>mp', '<cmd>MarkdownPreviewToggle<cr>', desc = 'Markdown Preview' } },
  },
}
