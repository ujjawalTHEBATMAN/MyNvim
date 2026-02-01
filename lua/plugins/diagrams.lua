-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                    DIAGRAMS AS CODE - EXCALIDRAW MODULE                   ║
-- ║         Treat diagrams as first-class citizens in your codebase          ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
--
-- Philosophy: Local-first, version-controlled diagrams that live with your code.
-- Architecture: Neovim → Bash Bridge → Browser PWA (File System Access API)
--
-- NO EXTERNAL PLUGIN REQUIRED - Pure Lua implementation
--

-- ═══════════════════════════════════════════════════════════════════════════
-- Configuration
-- ═══════════════════════════════════════════════════════════════════════════
local M = {}

M.config = {
  -- Directory for diagrams relative to project root
  directory = "docs/diagrams",
  -- Command to open excalidraw (our bridge script)
  open_command = "excalidraw-open",
  -- Default template for new diagrams
  template = [[{
  "type": "excalidraw",
  "version": 2,
  "source": "nvim-excalidraw",
  "elements": [],
  "appState": {
    "gridSize": null,
    "viewBackgroundColor": "#ffffff"
  },
  "files": {}
}]],
}

-- ═══════════════════════════════════════════════════════════════════════════
-- Helper Functions
-- ═══════════════════════════════════════════════════════════════════════════

-- Get the project root (git root or cwd)
local function get_project_root()
  local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
  if vim.v.shell_error == 0 and git_root ~= "" then
    return git_root
  end
  return vim.fn.getcwd()
end

-- Get the diagrams directory path
local function get_diagrams_dir()
  return get_project_root() .. "/" .. M.config.directory
end

-- Ensure diagrams directory exists
local function ensure_diagrams_dir()
  local dir = get_diagrams_dir()
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
    vim.notify("📁 Created: " .. dir, vim.log.levels.INFO)
  end
  return dir
end

-- Check if file is an excalidraw file
local function is_excalidraw_file(filepath)
  return filepath and filepath:match("%.excalidraw$") ~= nil
end

-- ═══════════════════════════════════════════════════════════════════════════
-- Core Functions
-- ═══════════════════════════════════════════════════════════════════════════

-- Create a new excalidraw diagram
function M.create(name)
  local diagrams_dir = ensure_diagrams_dir()
  
  if not name or name == "" then
    vim.ui.input({ prompt = "Diagram name (without .excalidraw): " }, function(input)
      if input and input ~= "" then
        M.create(input)
      end
    end)
    return
  end
  
  -- Sanitize the filename
  local sanitized = name:gsub("%s+", "-"):gsub("[^%w%-_]", "")
  local filepath = diagrams_dir .. "/" .. sanitized .. ".excalidraw"
  
  -- Check if file already exists
  if vim.fn.filereadable(filepath) == 1 then
    vim.notify("⚠️  File already exists: " .. filepath, vim.log.levels.WARN)
    vim.cmd("edit " .. vim.fn.fnameescape(filepath))
    return
  end
  
  -- Write the template
  local file = io.open(filepath, "w")
  if file then
    file:write(M.config.template)
    file:close()
    vim.notify("📊 Created: " .. filepath, vim.log.levels.INFO)
    vim.cmd("edit " .. vim.fn.fnameescape(filepath))
  else
    vim.notify("❌ Failed to create: " .. filepath, vim.log.levels.ERROR)
  end
end

-- Open an excalidraw file in browser
function M.open(filepath)
  filepath = filepath or vim.api.nvim_buf_get_name(0)
  
  if not is_excalidraw_file(filepath) then
    vim.notify("⚠️  Not an .excalidraw file", vim.log.levels.WARN)
    return
  end
  
  -- Check if bridge script exists
  local bridge_script = vim.fn.exepath(M.config.open_command)
  if bridge_script == "" then
    vim.notify("❌ Bridge script not found: " .. M.config.open_command, vim.log.levels.ERROR)
    vim.notify("💡 Make sure excalidraw-open is in your $PATH", vim.log.levels.INFO)
    return
  end
  
  -- Ensure file exists on disk (save if modified)
  if vim.bo.modified then
    vim.cmd("write")
  end
  
  -- Launch the browser
  vim.fn.jobstart({ M.config.open_command, filepath }, {
    detach = true,
    on_stderr = function(_, data)
      if data and data[1] ~= "" then
        vim.notify("Excalidraw: " .. table.concat(data, "\n"), vim.log.levels.INFO)
      end
    end,
  })
  
  vim.notify("🎨 Opening in browser: " .. vim.fn.fnamemodify(filepath, ":t"), vim.log.levels.INFO)
end

-- Find and open an existing diagram
function M.find()
  local diagrams_dir = get_diagrams_dir()
  
  if vim.fn.isdirectory(diagrams_dir) == 0 then
    vim.notify("📁 No diagrams directory found at: " .. diagrams_dir, vim.log.levels.WARN)
    vim.notify("💡 Create one with :ExcalidrawCreate", vim.log.levels.INFO)
    return
  end
  
  -- Try to use Telescope if available
  local ok, telescope = pcall(require, "telescope.builtin")
  if ok then
    telescope.find_files({
      cwd = diagrams_dir,
      prompt_title = "📊 Select Diagram",
      find_command = { "fd", "--type", "f", "-e", "excalidraw" },
    })
  else
    -- Fallback to native vim picker
    vim.cmd("edit " .. vim.fn.fnameescape(diagrams_dir))
  end
end

-- List all diagrams in the project
function M.list()
  local diagrams_dir = get_diagrams_dir()
  local files = vim.fn.glob(diagrams_dir .. "/*.excalidraw", false, true)
  
  if #files == 0 then
    vim.notify("📭 No diagrams found in: " .. diagrams_dir, vim.log.levels.INFO)
    return
  end
  
  vim.notify("📊 Diagrams in project:", vim.log.levels.INFO)
  for _, file in ipairs(files) do
    print("  • " .. vim.fn.fnamemodify(file, ":t"))
  end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- Plugin Spec (for lazy.nvim to recognize this file)
-- ═══════════════════════════════════════════════════════════════════════════
return {
  -- This is a virtual plugin spec - no external repo needed
  {
    dir = vim.fn.stdpath("config") .. "/lua/plugins", -- Points to itself
    name = "excalidraw-local",
    lazy = false,
    priority = 100,
    
    keys = {
      { "<leader>de", desc = "+Excalidraw Diagrams" },
      { "<leader>dec", function() M.create() end, desc = "Create diagram" },
      { "<leader>deo", function() M.open() end, desc = "Open in browser" },
      { "<leader>def", function() M.find() end, desc = "Find diagrams" },
      { "<leader>del", function() M.list() end, desc = "List diagrams" },
    },
    
    config = function()
      -- Register filetype for .excalidraw files
      vim.filetype.add({
        extension = {
          excalidraw = "json",
        },
      })
      
      -- Create user commands
      vim.api.nvim_create_user_command("ExcalidrawCreate", function(opts)
        M.create(opts.args ~= "" and opts.args or nil)
      end, { nargs = "?", desc = "Create new Excalidraw diagram" })
      
      vim.api.nvim_create_user_command("ExcalidrawOpen", function()
        M.open()
      end, { desc = "Open current diagram in browser" })
      
      vim.api.nvim_create_user_command("ExcalidrawFind", function()
        M.find()
      end, { desc = "Find and open an existing diagram" })
      
      vim.api.nvim_create_user_command("ExcalidrawList", function()
        M.list()
      end, { desc = "List all diagrams in project" })
      
      -- Auto-open .excalidraw files in browser when pressing <CR> or gf
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "json",
        callback = function()
          local bufname = vim.api.nvim_buf_get_name(0)
          if is_excalidraw_file(bufname) then
            vim.keymap.set("n", "<CR>", function() M.open() end, { 
              buffer = true, 
              desc = "Open in Excalidraw" 
            })
            vim.keymap.set("n", "gx", function() M.open() end, { 
              buffer = true, 
              desc = "Open in Excalidraw" 
            })
          end
        end,
      })
    end,
  },
}
