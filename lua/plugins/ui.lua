-- lua/plugins/ui.lua
-- PERFORMANCE OPTIMIZED UI plugins - Maximum smoothness

return {
  -- Dependencies
  { 'nvim-lua/plenary.nvim', priority = 999 },
  { 'nvim-tree/nvim-web-devicons', lazy = true },

  -- ═══════════════════════════════════════════════════════════════════════
  -- LUALINE (Status line) - Optimized for performance
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    config = function()
      -- Minimal helper functions (reduced overhead)
      local function lsp_clients()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients == 0 then return '' end
        return '[' .. clients[1].name .. ']'  -- Only show first LSP for speed
      end
      
      -- JDTLS Monitor component (only shows in Java files)
      local function jdtls_monitor()
        -- Only render in Java files
        if vim.bo.filetype ~= 'java' then return '' end
        
        -- Try to get stats from jdtls-monitor module
        local ok, monitor = pcall(require, 'jdtls-monitor')
        if not ok then return '' end
        
        return monitor.get_statusline_component() or ''
      end

      require('lualine').setup({
        options = {
          theme = 'dracula',
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
          globalstatus = true,
          refresh = {
            statusline = 1000,  -- Reduce refresh rate for performance
            tabline = 1000,
            winbar = 1000,
          },
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff' },
          lualine_c = { { 'filename', path = 1, symbols = { modified = ' ●', readonly = ' 󰌾' } }, lsp_clients },
          lualine_x = { 'diagnostics', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { jdtls_monitor, 'location' },
        },
        extensions = { 'nvim-tree', 'trouble', 'lazy', 'quickfix' },
      })
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- BUFFERLINE - Simplified for speed
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'akinsho/bufferline.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    event = 'VeryLazy',
    config = function()
      require('bufferline').setup({
        options = {
          mode = 'buffers',
          numbers = 'ordinal',
          close_command = 'bdelete! %d',
          indicator = { style = 'underline' },  -- Simpler indicator
          buffer_close_icon = '󰅖',
          modified_icon = '●',
          diagnostics = false,  -- Disable for performance
          separator_style = 'thin',  -- Lighter separator
          offsets = { { filetype = 'NvimTree', text = '  Files', text_align = 'left' } },
          show_buffer_close_icons = false,  -- Reduce rendering
          show_close_icon = false,
          always_show_bufferline = true,
          hover = { enabled = false },  -- Disable hover for speed
        },
      })
      
      local map = vim.keymap.set
      map('n', '<Tab>', '<Cmd>BufferLineCycleNext<CR>', { desc = 'Next Buffer' })
      map('n', '<S-Tab>', '<Cmd>BufferLineCyclePrev<CR>', { desc = 'Prev Buffer' })
      for i = 1, 5 do map('n', '<leader>' .. i, '<Cmd>BufferLineGoToBuffer ' .. i .. '<CR>', { desc = 'Buffer ' .. i }) end
      map('n', '<leader>bd', '<Cmd>bdelete<CR>', { desc = 'Delete Buffer' })
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- ALPHA (Dashboard) - Lightweight
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'goolord/alpha-nvim',
    event = 'VimEnter',
    config = function()
      local alpha = require('alpha')
      local dashboard = require('alpha.themes.dashboard')
      
      dashboard.section.header.val = {
        '',
        '    ██████╗ ██████╗  █████╗  ██████╗██╗   ██╗██╗      █████╗     ',
        '    ██╔══██╗██╔══██╗██╔══██╗██╔════╝██║   ██║██║     ██╔══██╗    ',
        '    ██║  ██║██████╔╝███████║██║     ██║   ██║██║     ███████║    ',
        '    ██║  ██║██╔══██╗██╔══██║██║     ██║   ██║██║     ██╔══██║    ',
        '    ██████╔╝██║  ██║██║  ██║╚██████╗╚██████╔╝███████╗██║  ██║    ',
        '    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝    ',
        '',
        '              N E O V I M  -  Performance Mode                   ',
        '',
      }
      dashboard.section.header.opts.hl = 'DraculaPurple'
      
      dashboard.section.buttons.val = {
        dashboard.button('f', '󰈞  Find file', ':Telescope find_files <CR>'),
        dashboard.button('r', '󰄉  Recent files', ':Telescope oldfiles <CR>'),
        dashboard.button('t', '󰊄  Find text', ':Telescope live_grep <CR>'),
        dashboard.button('s', '󰦛  Restore Session', ':SessionRestore<CR>'),
        dashboard.button('c', '  Configuration', ':e $MYVIMRC<CR>'),
        dashboard.button('l', '󰒲  Lazy Plugins', ':Lazy<CR>'),
        dashboard.button('q', '󰩈  Quit', ':qa<CR>'),
      }
      
      local function footer()
        local stats = require('lazy').stats()
        local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
        return string.format('⚡ %d plugins in %.2fms | 🧛 Dracula Theme', stats.loaded, ms)
      end
      
      dashboard.section.footer.val = 'Loading...'
      vim.defer_fn(function() 
        dashboard.section.footer.val = footer()
        pcall(vim.cmd.AlphaRedraw) 
      end, 0)
      
      dashboard.opts.layout = {
        { type = 'padding', val = 2 },
        dashboard.section.header,
        { type = 'padding', val = 2 },
        dashboard.section.buttons,
        { type = 'padding', val = 1 },
        dashboard.section.footer,
      }
      
      alpha.setup(dashboard.opts)
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- SNACKS (Utilities) - Minimal setup
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'folke/snacks.nvim',
    event = 'VeryLazy',
    priority = 999,
    opts = {
      bigfile = { enabled = true, size = 1024 * 500 },  -- 500KB threshold
      notifier = { enabled = true, timeout = 2000 },
      quickfile = { enabled = true },
      statuscolumn = { enabled = false },  -- Disable for performance
      words = { enabled = false },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- NOICE (Modern UI) - HEAVILY OPTIMIZED
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = { 'MunifTanjim/nui.nvim' },
    opts = {
      -- Disable heavy features
      lsp = {
        progress = { enabled = false },
        signature = { enabled = false },
        hover = { enabled = false },
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
      },
      -- Minimal presets
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
      -- No animations
      views = {
        cmdline_popup = {
          border = { style = 'single' },
          position = { row = '50%', col = '50%' },
        },
      },
      -- Reduce message rendering
      routes = {
        { filter = { event = 'msg_show', kind = '', find = 'written' }, opts = { skip = true } },
        { filter = { event = 'msg_show', kind = 'search_count' }, opts = { skip = true } },
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- DRESSING (Beautiful UI) - Simplified
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'stevearc/dressing.nvim',
    event = 'VeryLazy',
    opts = {
      input = { enabled = true, border = 'single', relative = 'cursor' },
      select = { enabled = true, backend = { 'telescope', 'builtin' } },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- DROPBAR (Breadcrumbs) - Lightweight config
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'Bekaboo/dropbar.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('dropbar').setup({
        bar = { hover = false },
        menu = { quick_navigation = true },
      })
      vim.keymap.set('n', '<leader>pb', function() require('dropbar.api').pick() end, { desc = 'Pick Breadcrumb' })
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- SCROLLBAR - Optimized (no search handlers)
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'petertriho/nvim-scrollbar',
    event = 'BufReadPost',
    config = function()
      require('scrollbar').setup({
        handle = { color = '#44475A', blend = 30 },  -- Dracula selection color
        marks = {
          Error = { color = '#FF5555' },
          Warn = { color = '#FFB86C' },
          Info = { color = '#8BE9FD' },
          Hint = { color = '#50FA7B' },
          GitAdd = { color = '#50FA7B' },
          GitChange = { color = '#F1FA8C' },
          GitDelete = { color = '#FF5555' },
        },
        excluded_filetypes = { 'prompt', 'TelescopePrompt', 'noice', 'notify', 'alpha', 'NvimTree', 'lazy', 'mason' },
        handlers = {
          cursor = false,     -- Disable cursor tracking
          diagnostic = true,
          gitsigns = false,   -- Disable git (reduces overhead)
          handle = true,
          search = false,     -- IMPORTANT: Disable search handler (causes lag!)
        },
      })
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- STATUSCOL - Simplified
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'luukvbaal/statuscol.nvim',
    event = 'BufReadPost',
    config = function()
      local builtin = require('statuscol.builtin')
      require('statuscol').setup({
        relculright = true,
        segments = {
          { text = { builtin.foldfunc }, click = 'v:lua.ScFa' },
          { text = { '%s' }, click = 'v:lua.ScSa' },
          { text = { builtin.lnumfunc, ' ' }, click = 'v:lua.ScLa' },
        },
      })
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- FIDGET (LSP Progress) - Minimal
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'j-hui/fidget.nvim',
    event = 'LspAttach',
    opts = {
      progress = {
        poll_rate = 200,  -- Slower polling
        suppress_on_insert = true,
        display = { render_limit = 3, done_ttl = 1 },
      },
      notification = {
        poll_rate = 50,
        window = { winblend = 0, border = 'single' },
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- NEOSCROLL - BUTTER SMOOTH SCROLLING! 🧈
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'karb94/neoscroll.nvim',
    event = 'VeryLazy',
    config = function()
      require('neoscroll').setup({
        mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>', '<C-y>', '<C-e>', 'zt', 'zz', 'zb' },
        hide_cursor = false,
        stop_eof = true,
        respect_scrolloff = false,
        cursor_scrolls_alone = true,
        easing_function = 'sine',  -- Smooth easing
        pre_hook = nil,
        post_hook = nil,
        performance_mode = true,   -- CRITICAL: Enable performance mode
      })
      
      -- Custom scroll speed for extra smoothness
      local t = {}
      t['<C-u>'] = { 'scroll', { '-vim.wo.scroll', 'true', '80', 'sine' } }
      t['<C-d>'] = { 'scroll', { 'vim.wo.scroll', 'true', '80', 'sine' } }
      t['<C-b>'] = { 'scroll', { '-vim.api.nvim_win_get_height(0)', 'true', '120', 'sine' } }
      t['<C-f>'] = { 'scroll', { 'vim.api.nvim_win_get_height(0)', 'true', '120', 'sine' } }
      t['<C-y>'] = { 'scroll', { '-0.10', 'false', '40', 'sine' } }
      t['<C-e>'] = { 'scroll', { '0.10', 'false', '40', 'sine' } }
      t['zt']    = { 'zt', { '100' } }
      t['zz']    = { 'zz', { '100' } }
      t['zb']    = { 'zb', { '100' } }
      
      require('neoscroll.config').set_mappings(t)
    end,
  },

  -- NOTE: modes.nvim REMOVED - causes cursor movement lag
  -- NOTE: nvim-notify REMOVED - noice.nvim handles this
}
