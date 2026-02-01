-- lua/themes/init.lua
-- Simplified Theme Module - Dracula Only for Maximum Performance

local M = {}

-- Single theme configuration
M.themes = {
  {
    name = 'dracula',
    label = '🧛 Dracula',
    setup = function()
      local ok, dracula = pcall(require, 'dracula')
      if ok then
        dracula.setup({
          transparent_bg = true,
          italic_comment = true,
        })
        vim.cmd.colorscheme('dracula')
      end
    end,
  },
}

function M.get_theme(name)
  for _, theme in ipairs(M.themes) do
    if theme.name == name then return theme end
  end
  return M.themes[1]
end

function M.save_theme(name)
  local cache_dir = vim.fn.stdpath('cache')
  vim.fn.mkdir(cache_dir, 'p')
  local file = io.open(cache_dir .. '/last_theme.txt', 'w')
  if file then
    file:write(name)
    file:close()
  end
end

function M.load_last_theme()
  local cache_file = vim.fn.stdpath('cache') .. '/last_theme.txt'
  local file = io.open(cache_file, 'r')
  if file then
    local name = file:read('*l') or file:read('*a')
    file:close()
    name = name:gsub('%s+', '')
    if name ~= '' then return name end
  end
  return 'dracula'
end

function M.apply_theme(theme_name)
  local theme = M.get_theme(theme_name)
  
  local ok, err = pcall(theme.setup)
  if not ok then
    vim.notify('Failed to load theme: ' .. tostring(err), vim.log.levels.ERROR)
    return
  end
  
  M.save_theme(theme.name)
  vim.g.colors_name = theme.name
end

function M.toggle_theme()
  -- Single theme, just reapply
  M.apply_theme('dracula')
  vim.notify('🧛 Dracula Theme Active', vim.log.levels.INFO)
end

function M.show_telescope_picker()
  -- Single theme, just show info
  vim.notify('🧛 Dracula is the only theme (for maximum performance)', vim.log.levels.INFO)
end

function M.setup()
  -- Theme is already applied by the plugin
  vim.notify('🧛 Dracula Theme Ready', vim.log.levels.INFO)
end

return M
