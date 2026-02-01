-- lua/plugins/completion.lua
-- PERFORMANCE OPTIMIZED completion and snippets

return {
  -- ═══════════════════════════════════════════════════════════════════════
  -- LAZYDEV (Lua API completion)
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        { path = 'lazy.nvim', words = { 'Lazy' } },
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- NVIM-CMP (Main completion) - HEAVILY OPTIMIZED
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      
      -- Load snippets lazily
      require('luasnip.loaders.from_vscode').lazy_load()
      require('luasnip').filetype_extend('java', { 'javadoc' })

      -- Minimal icons for speed
      local kind_icons = {
        Text = '', Method = '󰆧', Function = '󰊕', Constructor = '',
        Field = '󰜢', Variable = '', Class = '󰠱', Interface = '',
        Module = '', Property = '󰜢', Keyword = '', Snippet = '',
        Color = '', File = '󰈙', Folder = '󰉋', EnumMember = '',
        Constant = '󰏿', Struct = '󰙅', Event = '', Operator = '',
      }

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        
        sources = cmp.config.sources(
          {
            { name = 'nvim_lsp', priority = 1000, max_item_count = 10 },  -- Reduced from 12
            { name = 'luasnip', priority = 750, max_item_count = 3 },    -- Reduced from 5
          },
          {
            { name = 'buffer', priority = 500, keyword_length = 5, max_item_count = 3 },  -- Higher keyword_length
            { name = 'path', priority = 250, keyword_length = 3, max_item_count = 3 },
          }
        ),
        
        -- ═══════════════════════════════════════════════════════════════════
        -- PERFORMANCE CRITICAL SETTINGS
        -- ═══════════════════════════════════════════════════════════════════
        performance = {
          debounce = 250,           -- Increased for high WPM typing
          throttle = 200,           -- Increased throttle
          fetching_timeout = 100,   -- Reduced for snappier feel
          async_budget = 1,         -- Minimal async work
          max_view_entries = 15,    -- Reduced visible entries
        },
        
        matching = {
          disallow_fuzzy_matching = false,
          disallow_fullfuzzy_matching = true,
          disallow_partial_fuzzy_matching = true,
          disallow_partial_matching = false,
          disallow_prefix_unmatching = false,
        },
        
        -- No ghost text
        experimental = { ghost_text = false },
        
        -- Simple window styling
        window = {
          completion = {
            border = 'single',
            winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,Search:None',
            col_offset = -3,
            side_padding = 0,
          },
          documentation = {
            border = 'single',
            max_height = 15,
            max_width = 60,
          },
        },
        
        -- Simplified formatting
        formatting = {
          fields = { 'abbr', 'kind', 'menu' },
          format = function(entry, vim_item)
            vim_item.kind = (kind_icons[vim_item.kind] or '') .. ' ' .. vim_item.kind
            vim_item.menu = ({
              nvim_lsp = '[LSP]',
              luasnip = '[Snip]',
              buffer = '[Buf]',
              path = '[Path]',
            })[entry.source.name]
            -- Truncate long completions
            vim_item.abbr = string.sub(vim_item.abbr, 1, 35)
            return vim_item
          end,
        },
      })

      -- Cmdline completion (minimal)
      pcall(function()
        cmp.setup.cmdline({ '/', '?' }, {
          mapping = cmp.mapping.preset.cmdline(),
          sources = { { name = 'buffer', max_item_count = 5 } },
        })
        
        cmp.setup.cmdline(':', {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources(
            { { name = 'path', max_item_count = 5 } },
            { { name = 'cmdline', max_item_count = 10 } }
          ),
        })
      end)
    end,
  },
}
