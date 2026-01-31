-- lua/plugins/competitive.lua
-- Competitive Programming plugins

return {
  -- LeetCode
  {
    'kawre/leetcode.nvim',
    build = ':TSUpdate html',
    lazy = false,
    dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim', 'MunifTanjim/nui.nvim', 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    opts = {
      lang = 'java',
      domain = 'com',
      storage = { home = vim.fn.stdpath('data') .. '/leetcode', cache = vim.fn.stdpath('cache') .. '/leetcode' },
      description = { position = 'left', width = '40%', show_stats = true },
      console = { open_on_runcode = true, size = { width = '75%', height = '75%' } },
      hooks = { ['enter'] = { function() vim.notify('🚀 LeetCode initialized!', vim.log.levels.INFO) end } },
      injector = { ['java'] = { before = { 'import java.util.*;', 'import java.io.*;', 'import java.math.*;', '' } } },
    },
    keys = {
      { '<leader>Ll', '<cmd>Leet menu<cr>', desc = 'LeetCode Menu' },
      { '<leader>Lr', '<cmd>Leet run<cr>', desc = 'Run Code' },
      { '<leader>Ls', '<cmd>Leet submit<cr>', desc = 'Submit Code' },
      { '<leader>Lp', '<cmd>Leet list<cr>', desc = 'Problem List' },
      { '<leader>Ld', '<cmd>Leet daily<cr>', desc = 'Daily Challenge' },
      { '<leader>Lc', '<cmd>Leet console<cr>', desc = 'Console' },
    },
  },

  -- CompetiTest
  {
    'xeluxee/competitest.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
    event = 'VeryLazy',
    keys = {
      { '<leader>Cp', '<cmd>CompetiTest receive problem<cr>', desc = 'Receive Problem' },
      { '<leader>Cc', '<cmd>CompetiTest receive contest<cr>', desc = 'Receive Contest' },
      { '<leader>Cr', '<cmd>CompetiTest run<cr>', desc = 'Run Test Cases' },
      { '<leader>Ca', '<cmd>CompetiTest add_testcase<cr>', desc = 'Add Test Case' },
      { '<leader>Ce', '<cmd>CompetiTest edit_testcase<cr>', desc = 'Edit Test Case' },
      { '<leader>Cs', '<cmd>CompetiTest show_ui<cr>', desc = 'Approve/Edit UI' },
    },
    config = function()
      require('competitest').setup({
        runner_ui = { interface = 'popup' },
        popup_ui = { total_width = 0.85, total_height = 0.8, layout = { { 1, 'tc' }, { 1, { { 1, 'so' }, { 1, 'eo' } } }, { 1, 'si' } } },
        received_problems_path = vim.fn.expand('~') .. '/competitive/$(JUDGE)/$(CONTEST)/$(PROBLEM).$(FEXT)',
        received_contests_directory = vim.fn.expand('~') .. '/competitive/$(JUDGE)/$(CONTEST)',
        testcases_directory = './testcases',
        compile_command = { java = { exec = 'javac', args = { '$(FNAME)' } } },
        run_command = { java = { exec = 'java', args = { '$(FNOEXT)' } } },
        template_file = { java = '/home/ujjawal/templates/cp.java' },
      })
    end,
  },
}
