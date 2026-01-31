-- lua/plugins/editor.lua
-- Editor navigation and file management plugins

return {
  -- Telescope (Fuzzy Finder)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim', { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }, 'nvim-telescope/telescope-ui-select.nvim' },
    cmd = 'Telescope',
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Find Files' },
      { '<leader>fg', '<cmd>Telescope live_grep<cr>', desc = 'Live Grep' },
      { '<leader>fb', '<cmd>Telescope buffers<cr>', desc = 'Buffers' },
      { '<leader>fh', '<cmd>Telescope help_tags<cr>', desc = 'Help Tags' },
      { '<leader>fr', '<cmd>Telescope oldfiles<cr>', desc = 'Recent Files' },
      { '<leader>fc', '<cmd>Telescope colorscheme<cr>', desc = 'Colorschemes' },
      { '<leader>fk', '<cmd>Telescope keymaps<cr>', desc = 'Keymaps' },
    },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')
      telescope.setup({
        defaults = {
          prompt_prefix = '  ', selection_caret = ' ', path_display = { 'truncate' },
          file_ignore_patterns = { 'node_modules', '.git/', 'target/', 'build/', '.gradle', '%.class', '%.jar' },
          mappings = { i = { ['<C-j>'] = actions.move_selection_next, ['<C-k>'] = actions.move_selection_previous } },
        },
        pickers = { find_files = { hidden = true, no_ignore = false }, colorscheme = { enable_preview = true } },
        extensions = { fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true, case_mode = 'smart_case' }, ['ui-select'] = { require('telescope.themes').get_dropdown({}) } },
      })
      telescope.load_extension('fzf'); telescope.load_extension('ui-select')
    end,
  },

  -- Harpoon (Quick file navigation)
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = 'VeryLazy',
    config = function()
      local harpoon = require('harpoon')
      harpoon:setup({ settings = { save_on_toggle = true, sync_on_ui_close = true, key = function() return vim.loop.cwd() end } })
      vim.keymap.set('n', '<leader>a', function() harpoon:list():add() end, { desc = 'Harpoon Add' })
      vim.keymap.set('n', '<C-e>', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = 'Harpoon Menu' })
      for i = 1, 4 do vim.keymap.set('n', string.format('<M-%d>', i), function() harpoon:list():select(i) end, { desc = 'Harpoon ' .. i }) end
      vim.keymap.set('n', '<leader>h1', function() vim.cmd('vsplit'); harpoon:list():select(1) end, { desc = 'Harpoon 1 Vsplit' })
      vim.keymap.set('n', '<leader>h2', function() vim.cmd('vsplit'); harpoon:list():select(2) end, { desc = 'Harpoon 2 Vsplit' })
    end,
  },

  -- Smart Splits
  {
    'mrjones2014/smart-splits.nvim',
    event = 'VeryLazy',
    config = function()
      local ss = require('smart-splits')
      ss.setup({ ignored_filetypes = { 'nofile', 'quickfix', 'prompt', 'NvimTree' }, ignored_buftypes = { 'NvimTree' }, default_amount = 3, at_edge = 'wrap' })
      vim.keymap.set('n', '<A-h>', ss.move_cursor_left, { desc = 'Left Split' })
      vim.keymap.set('n', '<A-j>', ss.move_cursor_down, { desc = 'Down Split' })
      vim.keymap.set('n', '<A-k>', ss.move_cursor_up, { desc = 'Up Split' })
      vim.keymap.set('n', '<A-l>', ss.move_cursor_right, { desc = 'Right Split' })
      vim.keymap.set('n', '<A-S-h>', ss.resize_left, { desc = 'Resize Left' })
      vim.keymap.set('n', '<A-S-j>', ss.resize_down, { desc = 'Resize Down' })
      vim.keymap.set('n', '<A-S-k>', ss.resize_up, { desc = 'Resize Up' })
      vim.keymap.set('n', '<A-S-l>', ss.resize_right, { desc = 'Resize Right' })
    end,
  },

  -- NvimTree (File explorer)
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = { 'NvimTreeToggle', 'NvimTreeFocus' },
    keys = { { '<leader>E', '<cmd>NvimTreeToggle<cr>', desc = 'Tree Toggle' }, { '<leader>e', '<cmd>NvimTreeFocus<cr>', desc = 'Explorer Focus' } },
    opts = {
      view = { width = 35, side = 'left', relativenumber = true },
      renderer = { add_trailing = false, group_empty = true, icons = { git_placement = 'after', glyphs = { folder = { arrow_closed = '▸', arrow_open = '▾', default = '📁', open = '📂' } } }, special_files = { 'Cargo.toml', 'Makefile', 'README.md', 'pom.xml', 'build.gradle' } },
      filters = { custom = { '^.git$', '^node_modules$', '^target$', '^build$', '^.gradle$', '^.idea$' } },
      git = { enable = true, ignore = false },
      actions = { open_file = { quit_on_open = false, resize_window = true } },
      diagnostics = { enable = true, show_on_dirs = true, icons = { hint = '󰌵', info = '', warning = '', error = '' } },
    },
  },

  -- Oil (File system editor)
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = { { '-', '<cmd>Oil<cr>', desc = 'Open Parent Directory' } },
    opts = { view_options = { show_hidden = true } },
  },

  -- Flash (Navigation)
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {},
    keys = {
      { 's', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash' },
      { 'S', mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end, desc = 'Flash Treesitter' },
      { 'r', mode = 'o', function() require('flash').remote() end, desc = 'Remote Flash' },
      { 'R', mode = { 'o', 'x' }, function() require('flash').treesitter_search() end, desc = 'Treesitter Search' },
      { '<c-s>', mode = { 'c' }, function() require('flash').toggle() end, desc = 'Toggle Flash Search' },
    },
  },

  -- Windows (Auto-resize)
  {
    'anuvyklack/windows.nvim',
    event = 'WinNew',
    dependencies = { 'anuvyklack/middleclass', 'anuvyklack/animation.nvim' },
    config = function()
      vim.o.winwidth = 10; vim.o.winminwidth = 10; vim.o.equalalways = false
      require('windows').setup({ autowidth = { enable = true, winwidth = 5 }, ignore = { buftype = { 'quickfix' }, filetype = { 'NvimTree', 'neo-tree', 'undotree' } }, animation = { enable = false } })
      vim.keymap.set('n', '<C-w>z', '<Cmd>WindowsMaximize<CR>', { desc = 'Maximize Window' })
      vim.keymap.set('n', '<C-w>=', '<Cmd>WindowsEqualize<CR>', { desc = 'Equalize Windows' })
    end,
  },

  -- Session Management
  {
    'rmagatti/auto-session',
    lazy = false,
    config = function()
      require('auto-session').setup({ log_level = 'error', auto_session_suppress_dirs = { '~/', '~/Downloads', '/', '/tmp' }, auto_save_enabled = true, auto_restore_enabled = true, auto_session_use_git_branch = true })
      vim.keymap.set('n', '<leader>Ss', '<cmd>SessionSave<cr>', { desc = 'Save Session' })
      vim.keymap.set('n', '<leader>Sr', '<cmd>SessionRestore<cr>', { desc = 'Restore Session' })
      vim.keymap.set('n', '<leader>Sd', '<cmd>SessionDelete<cr>', { desc = 'Delete Session' })
    end,
  },

  -- Which-Key
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    priority = 50,
    config = function()
      vim.defer_fn(function()
        local wk = require('which-key')
        wk.setup({ preset = 'modern', delay = 300, plugins = { marks = true, registers = true, spelling = { enabled = true, suggestions = 20 } }, win = { border = 'rounded', padding = { 1, 2 } }, icons = { breadcrumb = '', separator = '➜', group = '+' } })
        wk.add({
          { '<leader>r', group = 'Run/Refactor', icon = { icon = '', color = 'green' } },
          { '<leader>t', group = 'Theme/Toggle/Test', icon = { icon = '', color = 'cyan' } },
          { '<leader>h', group = 'Harpoon', icon = { icon = '⚓', color = 'blue' } },
          { '<leader>g', group = 'Git', icon = { icon = '', color = 'orange' } },
          { '<leader>S', group = 'Session', icon = { icon = '', color = 'yellow' } },
          { '<leader>s', group = 'Split/Search/Spectre', icon = { icon = '', color = 'blue' } },
          { '<leader>j', group = 'Java', icon = { icon = '☕', color = 'red' } },
          { '<leader>d', group = 'Debug', icon = { icon = '', color = 'red' } },
          { '<leader>e', group = 'Explorer', icon = { icon = '', color = 'blue' } },
          { '<leader>x', group = 'Diagnostics', icon = { icon = '', color = 'red' } },
          { '<leader>c', group = 'Code', icon = { icon = '', color = 'purple' } },
          { '<leader>b', group = 'Buffer', icon = { icon = '', color = 'blue' } },
          { '<leader>f', group = 'Find/Files', icon = { icon = '', color = 'green' } },
          { '<leader>l', group = 'LSP', icon = { icon = '', color = 'purple' } },
          { '<leader>z', group = 'Zen', icon = { icon = '🧘', color = 'cyan' } },
          { '<leader>R', group = 'REST', icon = { icon = '󰒍', color = 'yellow' } },
          { '<leader>p', group = 'Pick/Breadcrumb', icon = { icon = '', color = 'purple' } },
          { '<leader>a', group = 'AI/Add', icon = { icon = '󰚩', color = 'cyan' } },
          { '<leader>L', group = 'LeetCode', icon = { icon = '󰪶', color = 'orange' } },
          { '<leader>C', group = 'Competitive', icon = { icon = '󰆧', color = 'green' } },
          -- NEW: Power user groups
          { '<leader>o', group = 'Overseer/Outline', icon = { icon = '󰜎', color = 'yellow' } },
          { '<leader>n', group = 'Neogen/Generate', icon = { icon = '󰈙', color = 'green' } },
        })
        vim.keymap.set('n', '<leader>tt', function() local ok, themes = pcall(require, 'themes'); if ok then themes.toggle_theme() end end, { desc = 'Toggle Theme' })
        vim.keymap.set('n', '<leader>ts', function() local ok, themes = pcall(require, 'themes'); if ok then themes.show_telescope_picker() end end, { desc = 'Select Theme' })
      end, 0)
    end,
  },

  -- Mini.files (Miller-style explorer)
  {
    'echasnovski/mini.files',
    keys = {
      { '<leader>fm', function() require('mini.files').open(vim.api.nvim_buf_get_name(0), true) end, desc = 'Mini Files (Current)' },
      { '<leader>fM', function() require('mini.files').open(vim.loop.cwd(), true) end, desc = 'Mini Files (CWD)' },
    },
    opts = { windows = { preview = true, width_focus = 30, width_nofocus = 15, width_preview = 40 }, options = { permanent_delete = false, use_as_default_explorer = false }, mappings = { close = 'q', go_in = 'l', go_in_plus = '<CR>', go_out = 'h', go_out_plus = 'H' } },
  },
}
