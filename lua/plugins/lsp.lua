-- lua/plugins/lsp.lua
-- PERFORMANCE OPTIMIZED LSP configuration (Neovim 0.11+ compatible)

return {
  -- ═══════════════════════════════════════════════════════════════════════
  -- MASON (LSP Installer)
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'williamboman/mason.nvim',
    build = ':MasonUpdate',
    opts = {
      ui = {
        icons = { package_installed = '✓', package_pending = '➜', package_uninstalled = '✗' },
        border = 'single',
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- MASON-LSPCONFIG
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim', 'neovim/nvim-lspconfig' },
    opts = {
      ensure_installed = { 'jdtls', 'lua_ls', 'jsonls', 'yamlls' },
      automatic_installation = true,
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- LSPCONFIG (Neovim 0.11+ compatible - uses new API only)
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'hrsh7th/cmp-nvim-lsp' },
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Shared on_attach function for keymaps
      local on_attach = function(client, bufnr)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
        end
        
        map('gd', vim.lsp.buf.definition, 'Go to Definition')
        map('gD', vim.lsp.buf.declaration, 'Go to Declaration')
        map('gr', vim.lsp.buf.references, 'Go to References')
        map('gi', vim.lsp.buf.implementation, 'Go to Implementation')
        map('K', vim.lsp.buf.hover, 'Hover Documentation')
        map('<leader>k', vim.lsp.buf.signature_help, 'Signature Help')
        map('<leader>rn', vim.lsp.buf.rename, 'Rename')
        map('<leader>ca', vim.lsp.buf.code_action, 'Code Action')
        map('<leader>lf', function() vim.lsp.buf.format({ async = true }) end, 'Format')
        
        -- Enable inlay hints if supported (Neovim 0.10+)
        if client.supports_method('textDocument/inlayHint') then
          pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
        end
      end

      -- Check for Neovim 0.11+ new LSP API
      local has_new_api = vim.lsp.config ~= nil and type(vim.lsp.config) == 'function'
      
      if has_new_api then
        -- Neovim 0.11+ native API
        vim.lsp.config('lua_ls', {
          capabilities = capabilities,
          on_attach = on_attach,
          settings = {
            Lua = {
              diagnostics = { globals = { 'vim' } },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        })
        vim.lsp.enable('lua_ls')

        vim.lsp.config('jsonls', { capabilities = capabilities, on_attach = on_attach })
        vim.lsp.enable('jsonls')

        vim.lsp.config('yamlls', {
          capabilities = capabilities,
          on_attach = on_attach,
          settings = { yaml = { keyOrdering = false } },
        })
        vim.lsp.enable('yamlls')
      else
        -- Fallback for older Neovim versions (pre-0.11)
        local lspconfig = require('lspconfig')
        
        lspconfig.lua_ls.setup({
          capabilities = capabilities,
          on_attach = on_attach,
          settings = {
            Lua = {
              diagnostics = { globals = { 'vim' } },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        })

        lspconfig.jsonls.setup({ capabilities = capabilities, on_attach = on_attach })
        lspconfig.yamlls.setup({
          capabilities = capabilities,
          on_attach = on_attach,
          settings = { yaml = { keyOrdering = false } },
        })
      end
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- TROUBLE (Diagnostics)
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
      { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics' },
      { '<leader>cs', '<cmd>Trouble symbols toggle focus=false<cr>', desc = 'Symbols' },
    },
    opts = {
      position = 'bottom',
      height = 12,
      icons = true,
      mode = 'workspace_diagnostics',
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- GLANCE (LSP Peeking)
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'dnlhc/glance.nvim',
    cmd = 'Glance',
    keys = {
      { 'gpd', '<cmd>Glance definitions<CR>', desc = 'Peek Definitions' },
      { 'gpr', '<cmd>Glance references<CR>', desc = 'Peek References' },
      { 'gpi', '<cmd>Glance implementations<CR>', desc = 'Peek Implementations' },
    },
    opts = { border = { enable = true } },
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- SYMBOLS OUTLINE
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'simrat39/symbols-outline.nvim',
    cmd = { 'SymbolsOutline', 'SymbolsOutlineOpen' },
    keys = { { '<leader>co', '<cmd>SymbolsOutline<cr>', desc = 'Symbols Outline' } },
    opts = {
      highlight_hovered_item = true,
      show_guides = true,
      auto_preview = false,
      position = 'right',
      width = 25,
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- INC-RENAME
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'smjonas/inc-rename.nvim',
    cmd = 'IncRename',
    keys = {
      {
        '<leader>rN',
        function() return ':IncRename ' .. vim.fn.expand('<cword>') end,
        expr = true,
        desc = 'Inc Rename',
      },
    },
    opts = { input_buffer_type = 'dressing' },
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- LSP SIGNATURE
  -- ═══════════════════════════════════════════════════════════════════════
  {
    'ray-x/lsp_signature.nvim',
    event = 'LspAttach',
    opts = {
      bind = true,
      floating_window = true,
      floating_window_above_cur_line = true,
      hint_enable = false,
      fix_pos = false,
      always_trigger = false,
      timer_interval = 500,
      toggle_key = '<M-x>',
      handler_opts = { border = 'single' },
    },
  },
}
