-- lua/plugins/power.lua
-- Power user plugins for advanced workflows

return {
  -- ToggleTerm (Essential for IDE-like terminal experience)
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    keys = {
      { '<C-`>', '<cmd>ToggleTerm<cr>', desc = 'Toggle Terminal' },
      { '<leader>tf', '<cmd>ToggleTerm direction=float<cr>', desc = 'Float Terminal' },
      { '<leader>th', '<cmd>ToggleTerm direction=horizontal size=15<cr>', desc = 'Horizontal Terminal' },
      { '<leader>tv', '<cmd>ToggleTerm direction=vertical size=50<cr>', desc = 'Vertical Terminal' },
    },
    opts = {
      size = function(term) return term.direction == 'horizontal' and 15 or vim.o.columns * 0.4 end,
      open_mapping = [[<C-`>]],
      hide_numbers = true,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      persist_mode = true,
      direction = 'float',
      close_on_exit = true,
      shell = vim.o.shell,
      auto_scroll = true,
      float_opts = { border = 'curved', width = function() return math.floor(vim.o.columns * 0.85) end, height = function() return math.floor(vim.o.lines * 0.8) end, winblend = 3 },
      winbar = { enabled = false },
    },
  },

  -- Persistence (Better session management - replaces auto-session overhead)
  -- Note: Using auto-session from editor.lua, but this is a lighter alternative if needed

  -- Project.nvim (Smart project detection)
  {
    'ahmedkhalf/project.nvim',
    event = 'VeryLazy',
    config = function()
      require('project_nvim').setup({
        manual_mode = false,
        detection_methods = { 'lsp', 'pattern' },
        patterns = { '.git', 'pom.xml', 'build.gradle', 'package.json', 'Makefile', 'Cargo.toml', '>.config' },
        ignore_lsp = { 'null-ls' },
        exclude_dirs = { '~/.cargo/*', '~/.local/*', '/usr/*' },
        show_hidden = false,
        silent_chdir = true,
        scope_chdir = 'global',
      })
      -- Telescope integration
      pcall(function() require('telescope').load_extension('projects') end)
    end,
    keys = { { '<leader>fp', '<cmd>Telescope projects<cr>', desc = 'Find Projects' } },
  },

  -- Overseer (Task runner - like VSCode tasks)
  {
    'stevearc/overseer.nvim',
    cmd = { 'OverseerRun', 'OverseerToggle', 'OverseerTaskAction' },
    keys = {
      { '<leader>or', '<cmd>OverseerRun<cr>', desc = 'Run Task' },
      { '<leader>ot', '<cmd>OverseerToggle<cr>', desc = 'Task List' },
      { '<leader>ob', '<cmd>OverseerBuild<cr>', desc = 'Build' },
    },
    opts = {
      strategy = { 'toggleterm', direction = 'horizontal', open_on_start = true, close_on_exit = false },
      task_list = { direction = 'right', min_width = { 40, 0.2 }, max_width = { 80, 0.5 }, bindings = { ['<CR>'] = 'RunAction', ['q'] = 'Close', ['o'] = 'Open' } },
      templates = { 'builtin' },
    },
  },

  -- Neogen (Documentation generator)
  {
    'danymat/neogen',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    keys = {
      { '<leader>ng', function() require('neogen').generate() end, desc = 'Generate Docs' },
      { '<leader>nf', function() require('neogen').generate({ type = 'func' }) end, desc = 'Generate Function Doc' },
      { '<leader>nc', function() require('neogen').generate({ type = 'class' }) end, desc = 'Generate Class Doc' },
    },
    opts = { snippet_engine = 'luasnip', languages = { java = { template = { annotation_convention = 'javadoc' } }, lua = { template = { annotation_convention = 'emmylua' } } } },
  },

  -- Outline (Better symbols outline - alternative to symbols-outline.nvim)
  {
    'hedyhli/outline.nvim',
    cmd = { 'Outline', 'OutlineOpen' },
    keys = { { '<leader>o', '<cmd>Outline<cr>', desc = 'Toggle Outline' } },
    opts = {
      outline_window = { position = 'right', width = 25, relative_width = true, auto_close = false, auto_jump = false },
      symbols = { filter = { 'String', 'Number', 'Boolean', exclude = true } },
      preview_window = { auto_preview = false },
    },
  },

  -- Marks (Better marks visualization)
  {
    'chentoast/marks.nvim',
    event = 'VeryLazy',
    opts = {
      default_mappings = true,
      builtin_marks = { '.', '<', '>', '^' },
      cyclic = true,
      force_write_shada = false,
      refresh_interval = 250,
      sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
    },
  },
}
