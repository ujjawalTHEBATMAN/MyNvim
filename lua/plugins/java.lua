-- lua/plugins/java.lua
-- Java development plugins (nvim-java with JDTLS)

return {
  {
    'nvim-java/nvim-java',
    ft = 'java',
    priority = 100,
    dependencies = { 'neovim/nvim-lspconfig', 'williamboman/mason.nvim', 'williamboman/mason-lspconfig.nvim', 'mfussenegger/nvim-dap', 'rcarriga/nvim-dap-ui', 'nvim-neotest/nvim-nio', 'hrsh7th/cmp-nvim-lsp' },
    config = function()
      local ok_runtime, java_runtime = pcall(require, 'java-runtime')
      local runtimes = {}
      if ok_runtime then
        runtimes = java_runtime.get_jdtls_runtimes()
        java_runtime.setup_autocmd()
      else
        runtimes = { { name = 'JavaSE-25', path = '/usr/lib/jvm/java-25-openjdk', default = true } }
      end

      require('java').setup({
        jdtls = {
          jvm_args = { '-Xms128m', '-Xmx512m', '-XX:+UseG1GC', '-XX:+UseStringDeduplication', '-XX:MaxMetaspaceSize=128m' },
        },
        java = {
          configuration = { runtimes = runtimes },
          eclipse = { downloadSources = false },
          maven = { downloadSources = false, updateSnapshots = false },
          gradle = { enabled = true, wrapper = { enabled = true } },
          springboot = { enable = false },
          format = { enabled = true, settings = { profile = 'GoogleStyle' } },
          autobuild = { enabled = false },
          maxConcurrentBuilds = 1,
          referencesCodeLens = { enabled = false },
          implementationsCodeLens = { enabled = false },
          completion = { guessMethodArguments = true, overwrite = false, favoriteStaticMembers = { 'org.junit.Assert.*', 'org.junit.jupiter.api.Assertions.*', 'org.mockito.Mockito.*' } },
          inlayHints = { parameterNames = { enabled = 'literals' } },
          import = { gradle = { enabled = true, wrapper = { enabled = true } }, maven = { enabled = true }, exclusions = { '**/node_modules/**', '**/.git/**', '**/build/**', '**/target/**', '**/bin/**', '**/out/**' } },
          contentProvider = { preferred = 'fernflower' },
          saveActions = { organizeImports = true },
          signatureHelp = { enabled = true },
        },
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        pattern = '*.java',
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= 'jdtls' then return end
          if ok_runtime then
            local current = java_runtime.get_current_java_version()
            if current then vim.notify('☕ Java ' .. current .. ' (RAM optimized)', vim.log.levels.INFO) end
          end
          local map = function(keys, func, desc) vim.keymap.set('n', keys, func, { buffer = args.buf, desc = desc }) end
          map('gd', vim.lsp.buf.definition, 'Go to Definition')
          map('gD', vim.lsp.buf.declaration, 'Go to Declaration')
          map('gr', vim.lsp.buf.references, 'References')
          map('gi', vim.lsp.buf.implementation, 'Implementation')
          map('K', vim.lsp.buf.hover, 'Hover')
          map('<leader>rn', vim.lsp.buf.rename, 'Rename')
          map('<leader>ca', vim.lsp.buf.code_action, 'Code Action')
          map('<leader>oi', function() vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true }) end, 'Organize Imports')
        end,
      })
    end,
  },
}
