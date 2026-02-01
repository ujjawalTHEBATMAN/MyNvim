-- lua/plugins/treesitter.lua
-- PERFORMANCE OPTIMIZED Treesitter

return {
  -- ═══════════════════════════════════════════════════════════════════════
  -- TREESITTER (Syntax highlighting)
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    priority = 95,
    lazy = false,
    config = function()
      local ok, configs = pcall(require, 'nvim-treesitter.configs')
      if ok then
        configs.setup({
          ensure_installed = {
            'java', 'xml', 'yaml', 'json', 'lua', 'vim', 'vimdoc',
            'markdown', 'markdown_inline', 'bash', 'html', 'css',
            'javascript', 'typescript',
          },
          
          -- PERFORMANCE OPTIMIZED Highlighting
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
            disable = function(lang, buf)
              -- Disable for large files
              local max_filesize = 100 * 1024  -- 100 KB
              local ok_stat, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
              if ok_stat and stats and stats.size > max_filesize then
                return true
              end
            end,
          },
          
          -- Indent (only for smaller files)
          indent = {
            enable = true,
            disable = { 'yaml' },  -- YAML indent can be slow
          },
          
          -- Incremental selection
          incremental_selection = {
            enable = true,
            keymaps = {
              init_selection = '<CR>',
              node_incremental = '<CR>',
              scope_incremental = '<S-CR>',
              node_decremental = '<BS>',
            },
          },
          
          -- Textobjects (simplified for performance)
          textobjects = {
            select = {
              enable = true,
              lookahead = true,
              keymaps = {
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['ac'] = '@class.outer',
                ['ic'] = '@class.inner',
              },
            },
            move = {
              enable = true,
              set_jumps = true,
              goto_next_start = {
                [']f'] = '@function.outer',
                [']c'] = '@class.outer',
              },
              goto_previous_start = {
                ['[f'] = '@function.outer',
                ['[c'] = '@class.outer',
              },
            },
          },
        })
      end
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- TEXTOBJECTS
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = { 'BufReadPost', 'BufNewFile' },
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- CONTEXT (Sticky headers) - Optimized
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      enable = true,
      max_lines = 2,            -- Reduced from 3
      min_window_height = 15,   -- Larger minimum
      line_numbers = true,
      multiline_threshold = 10, -- Reduced from 20
      trim_scope = 'outer',
      mode = 'cursor',
      separator = nil,          -- No separator (faster rendering)
      zindex = 20,
      on_attach = function(buf)
        -- Disable for large files
        local max_filesize = 100 * 1024  -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return false
        end
        return true
      end,
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- AUTOTAG (Auto-close HTML/JSX tags)
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'windwp/nvim-ts-autotag',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = false,
      },
    },
  },
}
