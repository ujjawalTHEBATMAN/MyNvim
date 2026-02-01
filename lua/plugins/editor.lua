-- lua/plugins/editor.lua
-- PERFORMANCE OPTIMIZED editor plugins

return {
  -- ═══════════════════════════════════════════════════════════════════════
  -- TELESCOPE (Fuzzy Finder)
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      'nvim-telescope/telescope-ui-select.nvim',
    },
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
          prompt_prefix = '  ',
          selection_caret = ' ',
          path_display = { 'truncate' },
          file_ignore_patterns = { 'node_modules', '.git/', 'target/', 'build/', '.gradle', '%.class', '%.jar' },
          mappings = {
            i = {
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
              ['<Esc>'] = actions.close,
            },
          },
          -- Performance optimizations
          layout_config = {
            horizontal = { preview_width = 0.5 },
          },
          vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--max-filesize=1M',  -- Skip large files
          },
        },
        pickers = {
          find_files = { hidden = true, no_ignore = false },
          colorscheme = { enable_preview = true },
        },
        extensions = {
          fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true },
          ['ui-select'] = { require('telescope.themes').get_dropdown({}) },
        },
      })
      
      telescope.load_extension('fzf')
      telescope.load_extension('ui-select')
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- HARPOON (Quick file navigation)
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = 'VeryLazy',
    config = function()
      local harpoon = require('harpoon')
      harpoon:setup({
        settings = {
          save_on_toggle = true,
          sync_on_ui_close = true,
          key = function() return vim.loop.cwd() end,
        },
      })
      
      vim.keymap.set('n', '<leader>ha', function() harpoon:list():add() end, { desc = 'Harpoon Add' })
      vim.keymap.set('n', '<C-e>', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = 'Harpoon Menu' })
      
      for i = 1, 4 do
        vim.keymap.set('n', string.format('<M-%d>', i), function() harpoon:list():select(i) end, { desc = 'Harpoon ' .. i })
      end
      
      vim.keymap.set('n', '<leader>h1', function() vim.cmd('vsplit'); harpoon:list():select(1) end, { desc = 'Harpoon 1 Vsplit' })
      vim.keymap.set('n', '<leader>h2', function() vim.cmd('vsplit'); harpoon:list():select(2) end, { desc = 'Harpoon 2 Vsplit' })
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- SMART SPLITS - No animations
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'mrjones2014/smart-splits.nvim',
    event = 'VeryLazy',
    config = function()
      local ss = require('smart-splits')
      ss.setup({
        ignored_filetypes = { 'nofile', 'quickfix', 'prompt', 'NvimTree' },
        default_amount = 3,
        at_edge = 'stop',  -- Changed from 'wrap' for smoother feel
      })
      
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

  -- ═══════════════════════════════════════════════════════════════════════
  -- NVIMTREE (File explorer) - Optimized
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = { 'NvimTreeToggle', 'NvimTreeFocus' },
    keys = {
      { '<leader>E', '<cmd>NvimTreeToggle<cr>', desc = 'Tree Toggle' },
      { '<leader>e', '<cmd>NvimTreeFocus<cr>', desc = 'Explorer Focus' },
    },
    opts = {
      view = { width = 35, side = 'left', relativenumber = true },
      renderer = {
        icons = { git_placement = 'after' },
        special_files = { 'pom.xml', 'build.gradle', 'package.json' },
      },
      filters = { custom = { '^.git$', '^node_modules$', '^target$', '^build$' } },
      git = { enable = true, ignore = false },
      actions = { open_file = { quit_on_open = false } },
      diagnostics = { enable = false },  -- Disable for performance
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- OIL (File system editor)
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = { { '-', '<cmd>Oil<cr>', desc = 'Open Parent Directory' } },
    opts = { view_options = { show_hidden = true } },
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- FLASH (Navigation)
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {},
    keys = {
      { 's', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash' },
      { 'S', mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end, desc = 'Flash Treesitter' },
      { 'r', mode = 'o', function() require('flash').remote() end, desc = 'Remote Flash' },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- SESSION MANAGEMENT
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'rmagatti/auto-session',
    lazy = false,
    config = function()
      require('auto-session').setup({
        log_level = 'error',
        auto_session_suppress_dirs = { '~/', '~/Downloads', '/', '/tmp' },
        auto_save_enabled = true,
        auto_restore_enabled = true,
        auto_session_use_git_branch = true,
      })
      
      vim.keymap.set('n', '<leader>Ss', '<cmd>SessionSave<cr>', { desc = 'Save Session' })
      vim.keymap.set('n', '<leader>Sr', '<cmd>SessionRestore<cr>', { desc = 'Restore Session' })
      vim.keymap.set('n', '<leader>Sd', '<cmd>SessionDelete<cr>', { desc = 'Delete Session' })
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- WHICH-KEY
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    priority = 50,
    config = function()
      vim.defer_fn(function()
        local wk = require('which-key')
        wk.setup({
          preset = 'modern',
          delay = 300,
          plugins = { marks = true, registers = true },
          win = { border = 'single' },
          icons = { separator = '➜', group = '+' },
        })
        
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
          { '<leader>p', group = 'Pick/Breadcrumb', icon = { icon = '', color = 'purple' } },
          { '<leader>a', group = 'AI', icon = { icon = '󰚩', color = 'cyan' } },
          { '<leader>aa', group = '🤖 AI (Ollama)', icon = { icon = '󱜚', color = 'green' } },
          { '<leader>o', group = 'Overseer/Outline', icon = { icon = '󰜎', color = 'yellow' } },
          { '<leader>n', group = 'Neogen/Generate', icon = { icon = '󰈙', color = 'green' } },
          { '<leader>k', group = 'Knowledge', icon = { icon = '📚', color = 'purple' } },
        })
      end, 0)
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- MINI.FILES (Miller-style explorer)
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'echasnovski/mini.files',
    keys = {
      { '<leader>fm', function() require('mini.files').open(vim.api.nvim_buf_get_name(0), true) end, desc = 'Mini Files (Current)' },
      { '<leader>fM', function() require('mini.files').open(vim.loop.cwd(), true) end, desc = 'Mini Files (CWD)' },
    },
    opts = {
      windows = { preview = true, width_focus = 30, width_preview = 40 },
      options = { use_as_default_explorer = false },
    },
  },

  -- NOTE: windows.nvim REMOVED - animation.nvim dependency caused lag
}
