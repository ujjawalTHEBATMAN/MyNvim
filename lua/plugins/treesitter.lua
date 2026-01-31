-- lua/plugins/treesitter.lua
-- Treesitter and syntax plugins

return {
  -- Treesitter (Syntax highlighting)
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    priority = 95,
    lazy = false,
    config = function()
      local ok, configs = pcall(require, 'nvim-treesitter.configs')
      if ok then
        configs.setup({
          ensure_installed = { 'java', 'xml', 'yaml', 'json', 'lua', 'vim', 'vimdoc', 'markdown', 'markdown_inline', 'bash', 'html', 'css', 'javascript', 'typescript' },
          highlight = { enable = true, additional_vim_regex_highlighting = false },
          indent = { enable = true },
          textobjects = {
            select = {
              enable = true,
              lookahead = true,
              keymaps = { ['af'] = '@function.outer', ['if'] = '@function.inner', ['ac'] = '@class.outer', ['ic'] = '@class.inner' },
            },
          },
        })
      end
    end,
  },

  -- Textobjects
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = { 'BufReadPost', 'BufNewFile' },
  },

  -- Context (Sticky headers)
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = { enable = true, max_lines = 3, min_window_height = 10, line_numbers = true, multiline_threshold = 20, trim_scope = 'outer', mode = 'cursor', separator = '─', zindex = 20 },
  },

  -- Autotag (Auto-close HTML/JSX tags)
  {
    'windwp/nvim-ts-autotag',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = { opts = { enable_close = true, enable_rename = true, enable_close_on_slash = false } },
  },
}
