-- lua/plugins/completion.lua
-- Completion and snippets

return {
  -- LazyDev (Lua API completion)
  { 'folke/lazydev.nvim', ft = 'lua', opts = { library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } }, { path = 'snacks.nvim', words = { 'Snacks' } }, { path = 'lazy.nvim', words = { 'Lazy' } } } } },

  -- nvim-cmp (Main completion)
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = { 'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-buffer', 'hrsh7th/cmp-path', 'hrsh7th/cmp-cmdline', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip', 'rafamadriz/friendly-snippets' },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      require('luasnip.loaders.from_vscode').lazy_load()
      require('luasnip').filetype_extend('java', { 'javadoc' })

      local kind_icons = { Text = '', Method = '󰆧', Function = '󰊕', Constructor = '', Field = '󰜢', Variable = '', Class = '󰠱', Interface = '', Module = '', Property = '󰜢', Unit = '', Value = '', Enum = '', Keyword = '', Snippet = '', Color = '', File = '󰈙', Reference = '󰈇', Folder = '󰉋', EnumMember = '', Constant = '󰏿', Struct = '󰙅', Event = '', Operator = '', TypeParameter = '' }

      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace }),
          ['<Tab>'] = cmp.mapping(function(fallback) if cmp.visible() then cmp.select_next_item() elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump() else fallback() end end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback) if cmp.visible() then cmp.select_prev_item() elseif luasnip.jumpable(-1) then luasnip.jump(-1) else fallback() end end, { 'i', 's' }),
        }),
        sources = cmp.config.sources(
          { 
            { name = 'nvim_lsp', priority = 1000, max_item_count = 12 },
            { name = 'luasnip', priority = 750, max_item_count = 5 },
          },
          { 
            { name = 'buffer', priority = 500, keyword_length = 4, max_item_count = 3 },
            { name = 'path', priority = 250, keyword_length = 3, max_item_count = 5 },
          }
        ),
        -- PERFORMANCE OPTIMIZED
        performance = {
          debounce = 200,           -- Increased from 150 for high WPM
          throttle = 150,           -- Increased from 100
          fetching_timeout = 150,   -- Reduced from 200 for snappier feel
          async_budget = 1,         -- Reduce async work per cycle
          max_view_entries = 20,    -- Limit visible entries
        },
        matching = {
          disallow_fuzzy_matching = false,
          disallow_fullfuzzy_matching = true,  -- Faster matching
          disallow_partial_fuzzy_matching = true,
          disallow_partial_matching = false,
          disallow_prefix_unmatching = false,
        },
        experimental = { ghost_text = false },  -- Keep disabled for performance
        window = { completion = cmp.config.window.bordered(), documentation = cmp.config.window.bordered() },
        formatting = {
          fields = { 'abbr', 'kind', 'menu' },
          format = function(entry, vim_item)
            vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind] or '', vim_item.kind)
            vim_item.menu = ({ nvim_lsp = '[LSP]', luasnip = '[Snip]', buffer = '[Buf]', path = '[Path]' })[entry.source.name]
            -- Truncate long completions
            vim_item.abbr = string.sub(vim_item.abbr, 1, 40)
            return vim_item
          end,
        },
      })

      cmp.setup.cmdline({ '/', '?' }, { mapping = cmp.mapping.preset.cmdline(), sources = { { name = 'buffer' } } })
      cmp.setup.cmdline(':', { mapping = cmp.mapping.preset.cmdline(), sources = cmp.config.sources({ { name = 'path' } }, { { name = 'cmdline' } }) })
    end,
  },
}
