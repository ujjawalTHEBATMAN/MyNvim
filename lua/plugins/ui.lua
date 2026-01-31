-- lua/plugins/ui.lua
-- UI Enhancement plugins

return {
  -- Dependencies
  { 'nvim-lua/plenary.nvim', priority = 999 },
  { 'nvim-tree/nvim-web-devicons', lazy = true },

  -- Lualine (Status line)
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    config = function()
      local function lsp_clients()
        local clients = vim.lsp.get_active_clients({ bufnr = 0 })
        if #clients == 0 then return '' end
        local names = {}; for _, c in pairs(clients) do table.insert(names, c.name) end
        return '[' .. table.concat(names, ', ') .. ']'
      end
      local function java_version()
        if vim.bo.filetype == 'java' then
          local ver = os.getenv('JAVA_HOME') or ''
          return ver:match('java%-(%d+)') or ver:match('jdk%-(%d+)') or ''
        end
        return ''
      end
      local function macro_recording()
        local reg = vim.fn.reg_recording(); if reg == '' then return '' end
        return '󰑋 Recording @' .. reg
      end
      local function search_count()
        if vim.v.hlsearch == 0 then return '' end
        local ok, count = pcall(vim.fn.searchcount, { recompute = true })
        if not ok or count.total == 0 then return '' end
        if count.incomplete == 1 then return '?/?' end
        return string.format('%d/%s', count.current, count.total > count.maxcount and '>' .. count.maxcount or count.total)
      end
      require('lualine').setup({
        options = { theme = 'catppuccin', component_separators = { left = '', right = '' }, section_separators = { left = '', right = '' }, globalstatus = true },
        sections = {
          lualine_a = { 'mode', { macro_recording, color = { fg = '#f38ba8', gui = 'bold' } } },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { { 'filename', path = 1, symbols = { modified = ' ●', readonly = ' 󰌾', unnamed = ' [No Name]' } }, { lsp_clients, icon = '󰌘' } },
          lualine_x = { { search_count, icon = '' }, { java_version, icon = '☕', cond = function() return vim.bo.filetype == 'java' end }, 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
        extensions = { 'nvim-tree', 'trouble', 'mason', 'lazy', 'quickfix' },
      })
    end,
  },

  -- Bufferline
  {
    'akinsho/bufferline.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    event = 'VeryLazy',
    config = function()
      local hl = {}; local ok, chl = pcall(function() return require('catppuccin.groups.integrations.bufferline').get() end); if ok then hl = chl end
      require('bufferline').setup({
        options = {
          mode = 'buffers', numbers = 'ordinal', close_command = 'bdelete! %d', indicator = { icon = '▎', style = 'underline' },
          buffer_close_icon = '󰅖', modified_icon = '●', close_icon = '󰅙', left_trunc_marker = '', right_trunc_marker = '',
          diagnostics = 'nvim_lsp', diagnostics_indicator = function(count, level) return ' ' .. (level == 'error' and '' or level == 'warning' and '' or '') .. ' ' .. count end,
          separator_style = 'padded_slant', offsets = { { filetype = 'NvimTree', text = '  File Explorer', text_align = 'left', separator = true } },
          show_buffer_close_icons = true, show_close_icon = false, always_show_bufferline = true, themable = true,
          hover = { enabled = true, delay = 200, reveal = { 'close' } }, sort_by = 'insert_after_current',
        },
        highlights = hl,
      })
      local map = vim.keymap.set
      map('n', '<Tab>', '<Cmd>BufferLineCycleNext<CR>', { desc = 'Next Buffer' })
      map('n', '<S-Tab>', '<Cmd>BufferLineCyclePrev<CR>', { desc = 'Prev Buffer' })
      for i = 1, 5 do map('n', '<leader>' .. i, '<Cmd>BufferLineGoToBuffer ' .. i .. '<CR>', { desc = 'Buffer ' .. i }) end
      map('n', '<leader>bd', '<Cmd>bdelete<CR>', { desc = 'Delete Buffer' })
      map('n', '<leader>bD', '<Cmd>bdelete!<CR>', { desc = 'Force Delete' })
    end,
  },

  -- Alpha (Dashboard)
  {
    'goolord/alpha-nvim',
    event = 'VimEnter',
    config = function()
      local alpha = require('alpha')
      local dashboard = require('alpha.themes.dashboard')
      dashboard.section.header.val = { '', '   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣭⣿⣶⣿⣦⣼⣆         ', '    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       ', '          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄     ', '           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀ ⠢⣀⡀⠈⠙⠿⠄    ', '          ⢠⣿⣿⣿⠈  ⠡⠌⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   ', '   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠂  ⠢ ⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇    ', '  ⣟⣿⣿⣿⣿⣿⣿⣷⣻⣿⣿⣧⡢⣔⡣⣂  ⣿⣿⣿⣿⣿⣿⣿⠇     ', ' ⣿⣿⣿⣿⣿⣿⡟⣿⡿⣿⣿⣿⣿⣿⣿⣿⣽⣿⣿⣿⣿⣿⡟⠁      ', ' ⣿⣿⣿⣿⣿⣿⡇⣿⣿⣮⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠁       ', ' ⠛⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠛⠁            ', '', '     N E O V I M   -   The Hyperextensible Editor', '' }
      dashboard.section.header.opts.hl = 'AlphaHeader'
      dashboard.section.buttons.val = {
        dashboard.button('f', '󰈞  Find file', ':Telescope find_files <CR>'),
        dashboard.button('e', '  New file', ':ene <BAR> startinsert <CR>'),
        dashboard.button('r', '󰄉  Recent files', ':Telescope oldfiles <CR>'),
        dashboard.button('t', '󰊄  Find text', ':Telescope live_grep <CR>'),
        dashboard.button('s', '󰦛  Restore Session', ':SessionRestore<CR>'),
        dashboard.button('c', '  Configuration', ':e $MYVIMRC<CR>'),
        dashboard.button('l', '󰒲  Lazy Plugins', ':Lazy<CR>'),
        dashboard.button('m', '󱌣  Mason Packages', ':Mason<CR>'),
        dashboard.button('q', '󰩈  Quit', ':qa<CR>'),
      }
      local function footer()
        local stats = require('lazy').stats()
        local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
        local ver = vim.version()
        return string.format('⚡ Neovim v%d.%d.%d  󰏗 %d plugins in %.2fms', ver.major, ver.minor, ver.patch, stats.loaded, ms)
      end
      dashboard.section.footer.opts.hl = 'AlphaFooter'; dashboard.section.footer.val = 'Loading...'
      vim.defer_fn(function() dashboard.section.footer.val = footer(); pcall(vim.cmd.AlphaRedraw) end, 0)
      vim.api.nvim_create_autocmd('User', { pattern = 'LazyVimStarted', callback = function() vim.schedule(function() dashboard.section.footer.val = footer(); pcall(vim.cmd.AlphaRedraw) end) end })
      dashboard.opts.layout = { { type = 'padding', val = 2 }, dashboard.section.header, { type = 'padding', val = 2 }, dashboard.section.buttons, { type = 'padding', val = 1 }, dashboard.section.footer }
      vim.api.nvim_set_hl(0, 'AlphaHeader', { fg = '#cba6f7' }); vim.api.nvim_set_hl(0, 'AlphaFooter', { fg = '#6c7086', italic = true })
      alpha.setup(dashboard.opts)
    end,
  },

  -- Snacks (Utilities)
  { 'folke/snacks.nvim', event = 'VeryLazy', priority = 999, opts = { bigfile = { enabled = true }, notifier = { enabled = true, timeout = 3000 }, quickfile = { enabled = true }, statuscolumn = { enabled = true }, words = { enabled = false } } },

  -- Noice (Modern UI)
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = { 'MunifTanjim/nui.nvim', 'rcarriga/nvim-notify' },
    opts = {
      lsp = { progress = { enabled = false }, signature = { enabled = false }, hover = { enabled = false }, override = { ['vim.lsp.util.convert_input_to_markdown_lines'] = true, ['vim.lsp.util.stylize_markdown'] = true, ['cmp.entry.get_documentation'] = true } },
      presets = { bottom_search = true, command_palette = true, long_message_to_split = true, inc_rename = true, lsp_doc_border = true },
      views = { cmdline_popup = { border = { style = 'rounded', padding = { 0, 1 } } }, popupmenu = { border = { style = 'rounded', padding = { 0, 1 } } } },
    },
  },

  -- Dressing (Beautiful UI)
  {
    'stevearc/dressing.nvim',
    event = 'VeryLazy',
    opts = {
      input = { enabled = true, default_prompt = '➤ ', border = 'rounded', relative = 'cursor', prefer_width = 40, min_width = 20 },
      select = { enabled = true, backend = { 'telescope', 'builtin' }, builtin = { border = 'rounded', relative = 'editor' } },
    },
  },

  -- Dropbar (Breadcrumbs)
  {
    'Bekaboo/dropbar.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'nvim-telescope/telescope-fzf-native.nvim' },
    config = function()
      require('dropbar').setup({ bar = { hover = false, padding = { left = 1, right = 1 } }, menu = { quick_navigation = true, win_configs = { border = 'rounded' } } })
      vim.keymap.set('n', '<leader>pb', function() require('dropbar.api').pick() end, { desc = 'Pick Breadcrumb' })
    end,
  },

  -- NOTE: barbecue.nvim and nvim-navic removed (dropbar.nvim already provides breadcrumbs)

  -- Scrollbar
  {
    'petertriho/nvim-scrollbar',
    event = 'BufReadPost',
    dependencies = { 'kevinhwang91/nvim-hlslens', 'lewis6991/gitsigns.nvim' },
    config = function()
      local colors = require('catppuccin.palettes').get_palette('mocha')
      require('scrollbar').setup({
        handle = { color = colors.surface1, blend = 30 },
        marks = { Search = { color = colors.yellow }, Error = { color = colors.red }, Warn = { color = colors.peach }, Info = { color = colors.blue }, Hint = { color = colors.teal }, Misc = { color = colors.mauve }, GitAdd = { color = colors.green }, GitChange = { color = colors.yellow }, GitDelete = { color = colors.red } },
        excluded_filetypes = { 'prompt', 'TelescopePrompt', 'noice', 'notify', 'alpha', 'dashboard', 'NvimTree', 'lazy', 'mason' },
        handlers = { cursor = false, diagnostic = true, gitsigns = true, handle = true, search = false },
      })
      require('scrollbar.handlers.gitsigns').setup(); require('scrollbar.handlers.search').setup()
    end,
  },

  -- Statuscol
  {
    'luukvbaal/statuscol.nvim',
    event = 'BufReadPost',
    config = function()
      local builtin = require('statuscol.builtin')
      require('statuscol').setup({ relculright = true, segments = { { text = { builtin.foldfunc }, click = 'v:lua.ScFa' }, { text = { '%s' }, click = 'v:lua.ScSa' }, { text = { builtin.lnumfunc, ' ' }, condition = { true, builtin.not_empty }, click = 'v:lua.ScLa' } } })
    end,
  },

  -- Modes (Mode-based highlights)
  {
    'mvllow/modes.nvim',
    event = 'BufReadPost',
    opts = { colors = { copy = '#f5c359', delete = '#f38ba8', insert = '#a6e3a1', visual = '#cba6f7' }, line_opacity = 0.15, set_cursor = false, set_cursorline = false, set_number = true, ignore = { 'NvimTree', 'TelescopePrompt', 'alpha', 'lazy', 'mason' } },
  },

  -- Fidget (LSP Progress)
  {
    'j-hui/fidget.nvim',
    event = 'LspAttach',
    opts = { progress = { poll_rate = 100, suppress_on_insert = true, display = { render_limit = 5, done_ttl = 2, done_icon = '✔' } }, notification = { poll_rate = 10, filter = vim.log.levels.INFO, window = { winblend = 0, border = 'rounded', align = 'bottom' } } },
  },
}
