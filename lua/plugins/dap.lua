-- lua/plugins/dap.lua
-- Debug Adapter Protocol plugins

return {
  {
    'mfussenegger/nvim-dap',
    dependencies = { 'rcarriga/nvim-dap-ui', 'nvim-neotest/nvim-nio', 'theHamsta/nvim-dap-virtual-text' },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')

      dapui.setup({
        icons = { expanded = '', collapsed = '', current_frame = '' },
        controls = { icons = { pause = '', play = '', step_into = '', step_over = '', step_out = '', step_back = '', run_last = '', terminate = '' } },
      })

      require('nvim-dap-virtual-text').setup()

      dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
      dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
      dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end

      -- Keymaps
      vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>dB', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { desc = 'Conditional Breakpoint' })
      vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Continue/Start Debug' })
      vim.keymap.set('n', '<leader>do', dap.step_over, { desc = 'Step Over' })
      vim.keymap.set('n', '<leader>di', dap.step_into, { desc = 'Step Into' })
      vim.keymap.set('n', '<leader>du', dap.step_out, { desc = 'Step Out' })
      vim.keymap.set('n', '<leader>dt', dap.terminate, { desc = 'Terminate Debug' })
      vim.keymap.set('n', '<leader>dr', dap.repl.open, { desc = 'Open REPL' })
      vim.keymap.set('n', '<leader>dl', dap.run_last, { desc = 'Run Last' })
      vim.keymap.set('n', '<leader>de', dapui.eval, { desc = 'Eval Expression' })
    end,
  },
}
