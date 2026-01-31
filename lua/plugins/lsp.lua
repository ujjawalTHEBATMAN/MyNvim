-- lua/plugins/lsp.lua
-- LSP, Mason, and language server plugins

return {
  -- Mason (LSP Installer)
  {
    'williamboman/mason.nvim',
    build = ':MasonUpdate',
    opts = { ui = { icons = { package_installed = '✓', package_pending = '➜', package_uninstalled = '✗' }, border = 'rounded' } },
  },

  -- Mason-LSPConfig
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim', 'neovim/nvim-lspconfig' },
    opts = { ensure_installed = { 'jdtls', 'lua_ls', 'jsonls', 'yamlls' }, automatic_installation = true },
  },

  -- LSPConfig (Neovim 0.11+ compatible)
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'hrsh7th/cmp-nvim-lsp' },
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Shared on_attach function for keymaps
      local on_attach = function(client, bufnr)
        local map = function(keys, func, desc) vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc }) end
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
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
      end

      -- Use vim.lsp.config for Neovim 0.11+ (new API)
      -- This silences the deprecation warning and is future-proof
      local lsp_configs = {
        lua_ls = {
          capabilities = capabilities,
          on_attach = on_attach,
          settings = {
            Lua = {
              diagnostics = { globals = { 'vim' } },
              workspace = { library = vim.api.nvim_get_runtime_file('', true), checkThirdParty = false },
              telemetry = { enable = false },
              hint = { enable = true, setType = true },
            },
          },
        },
        jsonls = { capabilities = capabilities, on_attach = on_attach },
        yamlls = { capabilities = capabilities, on_attach = on_attach, settings = { yaml = { keyOrdering = false } } },
      }

      -- Apply configurations using the new API if available, fallback to old API
      for server, config in pairs(lsp_configs) do
        if vim.lsp.config and type(vim.lsp.config) == 'function' then
          -- Neovim 0.11+ native API
          vim.lsp.config(server, config)
          vim.lsp.enable(server)
        else
          -- Fallback for older Neovim versions
          require('lspconfig')[server].setup(config)
        end
      end
    end,
  },

  -- Trouble (Diagnostics)
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
      { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics' },
      { '<leader>cs', '<cmd>Trouble symbols toggle focus=false<cr>', desc = 'Symbols' },
      { '<leader>cl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', desc = 'LSP Definitions' },
    },
    opts = { position = 'bottom', height = 12, icons = true, mode = 'workspace_diagnostics', fold_open = '', fold_closed = '', group = true, padding = true, cycle_results = true },
  },

  -- Glance (LSP Peeking)
  {
    'dnlhc/glance.nvim',
    cmd = 'Glance',
    keys = {
      { 'gpd', '<cmd>Glance definitions<CR>', desc = 'Peek Definitions' },
      { 'gpr', '<cmd>Glance references<CR>', desc = 'Peek References' },
      { 'gpy', '<cmd>Glance type_definitions<CR>', desc = 'Peek Type Definitions' },
      { 'gpi', '<cmd>Glance implementations<CR>', desc = 'Peek Implementations' },
    },
    opts = { border = { enable = true, top_char = '―', bottom_char = '―' } },
  },

  -- Symbols Outline
  {
    'simrat39/symbols-outline.nvim',
    cmd = { 'SymbolsOutline', 'SymbolsOutlineOpen', 'SymbolsOutlineClose' },
    keys = { { '<leader>co', '<cmd>SymbolsOutline<cr>', desc = 'Symbols Outline' } },
    opts = { highlight_hovered_item = true, show_guides = true, auto_preview = false, position = 'right', relative_width = true, width = 25, autofold_depth = 2 },
  },

  -- Inc-Rename
  {
    'smjonas/inc-rename.nvim',
    cmd = 'IncRename',
    keys = { { '<leader>rn', function() return ':IncRename ' .. vim.fn.expand('<cword>') end, expr = true, desc = 'Inc Rename' } },
    opts = { input_buffer_type = 'dressing' },
  },

  -- LSP Signature
  {
    'ray-x/lsp_signature.nvim',
    event = 'LspAttach',
    opts = { bind = true, floating_window = true, floating_window_above_cur_line = true, hint_enable = false, fix_pos = false, always_trigger = false, timer_interval = 500, toggle_key = '<M-x>', handler_opts = { border = 'rounded' } },
  },
}
