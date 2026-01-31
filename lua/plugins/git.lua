-- lua/plugins/git.lua
-- Git integration plugins

return {
  -- Gitsigns
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('gitsigns').setup({
        signs = { add = { text = '┃' }, change = { text = '┃' }, delete = { text = '_' }, topdelete = { text = '‾' }, changedelete = { text = '~' } },
        signcolumn = true, numhl = false, linehl = false, word_diff = false,
        current_line_blame = true, current_line_blame_opts = { virt_text = true, virt_text_pos = 'eol', delay = 2000 },
        current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, opts) opts = opts or {}; opts.buffer = bufnr; vim.keymap.set(mode, l, r, opts) end
          map('n', ']c', function() if vim.wo.diff then return ']c' end; vim.schedule(gs.next_hunk); return '<Ignore>' end, { expr = true, desc = 'Next Hunk' })
          map('n', '[c', function() if vim.wo.diff then return '[c' end; vim.schedule(gs.prev_hunk); return '<Ignore>' end, { expr = true, desc = 'Prev Hunk' })
          map('n', '<leader>gs', gs.stage_hunk, { desc = 'Stage Hunk' })
          map('n', '<leader>gr', gs.reset_hunk, { desc = 'Reset Hunk' })
          map('v', '<leader>gs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, { desc = 'Stage Hunk' })
          map('v', '<leader>gr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, { desc = 'Reset Hunk' })
          map('n', '<leader>gS', gs.stage_buffer, { desc = 'Stage Buffer' })
          map('n', '<leader>gu', gs.undo_stage_hunk, { desc = 'Undo Stage' })
          map('n', '<leader>gR', gs.reset_buffer, { desc = 'Reset Buffer' })
          map('n', '<leader>gp', gs.preview_hunk, { desc = 'Preview Hunk' })
          map('n', '<leader>gb', function() gs.blame_line({ full = true }) end, { desc = 'Blame Line' })
          map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'Toggle Blame' })
          map('n', '<leader>gd', gs.diffthis, { desc = 'Diff This' })
          map('n', '<leader>gD', function() gs.diffthis('~') end, { desc = 'Diff This ~' })
        end,
      })
    end,
  },

  -- LazyGit
  {
    'kdheepak/lazygit.nvim',
    cmd = { 'LazyGit' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = { { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'LazyGit' } },
    config = function() vim.g.lazygit_floating_window_winblend = 0; vim.g.lazygit_floating_window_scaling_factor = 0.9 end,
  },

  -- Neogit
  {
    'NeogitOrg/neogit',
    dependencies = { 'nvim-lua/plenary.nvim', 'sindrets/diffview.nvim', 'nvim-telescope/telescope.nvim' },
    cmd = 'Neogit',
    keys = { { '<leader>gn', '<cmd>Neogit<cr>', desc = 'Neogit' }, { '<leader>gc', '<cmd>Neogit commit<cr>', desc = 'Git Commit' } },
    opts = { disable_hint = false, graph_style = 'ascii', integrations = { telescope = true, diffview = true } },
  },

  -- Diffview
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
    keys = { { '<leader>gv', '<cmd>DiffviewOpen<cr>', desc = 'Diff View Open' }, { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = 'File History' } },
  },
}
