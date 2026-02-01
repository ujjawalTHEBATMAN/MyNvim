-- lua/plugins/knowledge.lua
-- Obsidian.nvim: Bridge your Java code to your "First Principles" notes
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                    KNOWLEDGE MANAGEMENT LAYER                             ║
-- ║         Link code ↔ notes for deep understanding                         ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

return {
  {
    'epwalsh/obsidian.nvim',
    version = '*',
    lazy = true,
    ft = 'markdown',
    -- Only load when opening files in your vault
    event = {
      -- Replace with your actual Obsidian vault path(s)
      'BufReadPre ' .. vim.fn.expand('~') .. '/Documents/Obsidian/**/*.md',
      'BufNewFile ' .. vim.fn.expand('~') .. '/Documents/Obsidian/**/*.md',
      -- Alternative common paths
      'BufReadPre ' .. vim.fn.expand('~') .. '/Obsidian/**/*.md',
      'BufNewFile ' .. vim.fn.expand('~') .. '/Obsidian/**/*.md',
      'BufReadPre ' .. vim.fn.expand('~') .. '/notes/**/*.md',
      'BufNewFile ' .. vim.fn.expand('~') .. '/notes/**/*.md',
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'hrsh7th/nvim-cmp',         -- For completion
      'nvim-telescope/telescope.nvim', -- For fuzzy finding
    },
    keys = {
      -- Quick access (even outside vault)
      { '<leader>ko', '<cmd>ObsidianOpen<cr>', desc = 'Open in Obsidian App' },
      { '<leader>kn', '<cmd>ObsidianNew<cr>', desc = 'New Note' },
      { '<leader>ks', '<cmd>ObsidianSearch<cr>', desc = 'Search Notes' },
      { '<leader>kq', '<cmd>ObsidianQuickSwitch<cr>', desc = 'Quick Switch' },
      { '<leader>kb', '<cmd>ObsidianBacklinks<cr>', desc = 'Show Backlinks' },
      { '<leader>kl', '<cmd>ObsidianLinks<cr>', desc = 'Show Links' },
      { '<leader>kt', '<cmd>ObsidianTags<cr>', desc = 'Search by Tags' },
      { '<leader>kT', '<cmd>ObsidianTemplate<cr>', desc = 'Insert Template' },
      { '<leader>kd', '<cmd>ObsidianToday<cr>', desc = "Today's Note" },
      { '<leader>ky', '<cmd>ObsidianYesterday<cr>', desc = "Yesterday's Note" },
      { '<leader>kw', '<cmd>ObsidianWorkspace<cr>', desc = 'Switch Workspace' },
      -- Visual mode: link selection to a note
      { '<leader>kL', ':ObsidianLink<cr>', desc = 'Link Selection', mode = 'v' },
      { '<leader>ke', ':ObsidianExtractNote<cr>', desc = 'Extract to Note', mode = 'v' },
    },
    opts = {
      -- ═══════════════════════════════════════════════════════════════════════
      -- VAULT CONFIGURATION
      -- Modify these paths to match your Obsidian setup
      -- ═══════════════════════════════════════════════════════════════════════
      workspaces = {
        {
          name = 'First Principles',
          path = '~/Documents/Obsidian/FirstPrinciples',
          -- If this doesn't exist, obsidian.nvim will prompt to create
        },
        {
          name = 'Java Notes',
          path = '~/Documents/Obsidian/Java',
        },
        {
          name = 'Personal',
          path = '~/Documents/Obsidian/Personal',
        },
        -- Add more workspaces as needed
      },

      -- ═══════════════════════════════════════════════════════════════════════
      -- NOTE ID & TITLE CONFIGURATION
      -- ═══════════════════════════════════════════════════════════════════════
      -- How note IDs are generated (used in links)
      note_id_func = function(title)
        -- Clean, readable IDs based on title
        local suffix = ''
        if title ~= nil then
          -- Sanitize title: lowercase, replace spaces with dashes
          suffix = title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
        else
          -- Random ID for untitled notes
          suffix = tostring(os.time())
        end
        return suffix
      end,

      -- Where new notes are created
      notes_subdir = 'inbox',

      -- Daily notes configuration
      daily_notes = {
        folder = 'daily',
        date_format = '%Y-%m-%d',
        alias_format = '%B %-d, %Y',
        template = nil, -- Set to a template file name if you have one
      },

      -- ═══════════════════════════════════════════════════════════════════════
      -- TEMPLATES (Optional: Create these in your vault)
      -- ═══════════════════════════════════════════════════════════════════════
      templates = {
        folder = 'templates',
        date_format = '%Y-%m-%d',
        time_format = '%H:%M',
        substitutions = {
          -- Custom substitutions for templates
          -- Example: {{java_version}} → output of 'java --version'
        },
      },

      -- ═══════════════════════════════════════════════════════════════════════
      -- COMPLETION (Works with nvim-cmp)
      -- ═══════════════════════════════════════════════════════════════════════
      completion = {
        nvim_cmp = true,
        min_chars = 2, -- Trigger completion after 2 characters
      },

      -- ═══════════════════════════════════════════════════════════════════════
      -- UI CONFIGURATION
      -- ═══════════════════════════════════════════════════════════════════════
      ui = {
        enable = true,
        update_debounce = 200,
        -- Checkbox icons
        checkboxes = {
          [' '] = { char = '󰄱', hl_group = 'ObsidianTodo' },
          ['x'] = { char = '', hl_group = 'ObsidianDone' },
          ['>'] = { char = '', hl_group = 'ObsidianRightArrow' },
          ['~'] = { char = '󰰱', hl_group = 'ObsidianTilde' },
        },
        -- Bullet point icon
        bullets = { char = '•', hl_group = 'ObsidianBullet' },
        -- External link icon
        external_link_icon = { char = '', hl_group = 'ObsidianExtLinkIcon' },
        -- Reference text
        reference_text = { hl_group = 'ObsidianRefText' },
        -- Highlight groups for tags
        highlight_text = { hl_group = 'ObsidianHighlightText' },
        -- Tags
        tags = { hl_group = 'ObsidianTag' },
        -- Block IDs
        block_ids = { hl_group = 'ObsidianBlockID' },
        -- Wikilink formatting
        hl_groups = {
          ObsidianTodo = { bold = true, fg = '#f78c6c' },
          ObsidianDone = { bold = true, fg = '#89ddff' },
          ObsidianRightArrow = { bold = true, fg = '#f78c6c' },
          ObsidianTilde = { bold = true, fg = '#ff5370' },
          ObsidianBullet = { bold = true, fg = '#89ddff' },
          ObsidianRefText = { underline = true, fg = '#c792ea' },
          ObsidianExtLinkIcon = { fg = '#c792ea' },
          ObsidianTag = { italic = true, fg = '#89ddff' },
          ObsidianBlockID = { italic = true, fg = '#89ddff' },
          ObsidianHighlightText = { bg = '#75662e' },
        },
      },

      -- ═══════════════════════════════════════════════════════════════════════
      -- MAPPINGS (Buffer-local when in vault)
      -- ═══════════════════════════════════════════════════════════════════════
      mappings = {
        -- "Smart action": Follow link under cursor or toggle checkbox
        ['gf'] = {
          action = function()
            return require('obsidian').util.gf_passthrough()
          end,
          opts = { noremap = false, expr = true, buffer = true },
        },
        -- Toggle checkbox
        ['<leader>kc'] = {
          action = function()
            return require('obsidian').util.toggle_checkbox()
          end,
          opts = { buffer = true, desc = 'Toggle Checkbox' },
        },
        -- Create new note from selection (visual mode)
        ['<CR>'] = {
          action = function()
            return require('obsidian').util.smart_action()
          end,
          opts = { buffer = true, expr = true },
        },
      },

      -- ═══════════════════════════════════════════════════════════════════════
      -- FOLLOW URL ACTION
      -- ═══════════════════════════════════════════════════════════════════════
      follow_url_func = function(url)
        vim.fn.jobstart({ 'xdg-open', url }) -- Linux
      end,

      -- ═══════════════════════════════════════════════════════════════════════
      -- PICKER (Telescope integration)
      -- ═══════════════════════════════════════════════════════════════════════
      picker = {
        name = 'telescope.nvim',
        mappings = {
          new = '<C-x>',
          insert_link = '<C-l>',
        },
      },

      -- ═══════════════════════════════════════════════════════════════════════
      -- ADVANCED OPTIONS
      -- ═══════════════════════════════════════════════════════════════════════
      -- Disable wiki-style links (use markdown links instead)
      wiki_link_func = function(opts)
        if opts.id == nil then
          return string.format('[[%s]]', opts.label)
        elseif opts.label ~= opts.id then
          return string.format('[[%s|%s]]', opts.id, opts.label)
        else
          return string.format('[[%s]]', opts.id)
        end
      end,

      -- Frontmatter customization
      note_frontmatter_func = function(note)
        local out = {
          id = note.id,
          aliases = note.aliases,
          tags = note.tags,
          created = os.date('%Y-%m-%d'),
        }
        -- Preserve any existing frontmatter
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end
        return out
      end,
    },

    config = function(_, opts)
      require('obsidian').setup(opts)

      -- Register which-key group
      local ok, wk = pcall(require, 'which-key')
      if ok then
        wk.add({
          { '<leader>k', group = 'Knowledge (Obsidian)', icon = { icon = '📚', color = 'purple' } },
        })
      end

      vim.notify('📚 Obsidian.nvim loaded. Use <leader>k* for knowledge commands.', vim.log.levels.INFO)
    end,
  },
}
